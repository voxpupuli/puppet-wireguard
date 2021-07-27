#
# @summary manages a wireguard setup
#
# @param interface the title of the defined resource, will be used for the wg interface
# @param input_interface ethernet interface where the wireguard packages will enter the system, used for firewall rules
# @param manage_firewall if true, a ferm rule will be created
# @param dport destination for firewall rules / where our wg instance will listen on. defaults to the last digits from the title
# @param source_addresses an array of ip addresses from where we receive wireguard connections
# @param destination_addresses array of addresses where the remote peer connects to (our local ips), used for firewalling
# @param public_key base64 encoded pubkey from the remote peer
# @param endpoint fqdn:port or ip:port where we connect to
# @param addresses different addresses for the systemd-networkd configuration
#
# @author Tim Meusel <tim@bastelfreak.de>
#
# @example
#  Peer with one node and setup dualstack firewall rules
#  wireguard::interface {'as2273':
#    source_addresses => ['2003:4f8:c17:4cf::1', '149.9.255.4'],
#    public_key       => 'BcxLll1BVxGQ5DeijroesjroiesjrjvX+EBhS4vcDn0R0=',
#    endpoint         => 'wg.example.com:53668',
#    addresses        => [{'Address' => '192.168.123.6/30',},{'Address' => 'fe80::beef:1/64'},],
#  }
#
#  Peer with one node and setup dualstack firewall rules with peers in a different layer2
#  wireguard::interface {'as2273':
#    source_addresses => ['2003:4f8:c17:4cf::1', '149.9.255.4'],
#    public_key       => 'BcxLll1BVxGQ5DeijroesjroiesjrjvX+EBhS4vcDn0R0=',
#    endpoint         => 'wg.example.com:53668',
#    addresses        => [{'Address' => '192.168.218.87/32', 'Peer' => '172.20.53.97/32'}, {'Address' => 'fe80::ade1/64',},],
#  }
#
#  Create a passive wireguard interface that listens for incoming connections. Useful when the other side has a dynamic IP / is behind NAT
#  wireguard::interface {'as2273':
#    source_addresses => ['2003:4f8:c17:4cf::1', '149.9.255.4'],
#    public_key       => 'BcxLll1BVxGQ5DeijroesjroiesjrjvX+EBhS4vcDn0R0=',
#    dport            => 53668,
#    addresses        => [{'Address' => '192.168.218.87/32', 'Peer' => '172.20.53.97/32'}, {'Address' => 'fe80::ade1/64',},],
#  }
define wireguard::interface (
  String[1] $public_key,
  Optional[String[1]] $endpoint = undef,
  Array[Stdlib::IP::Address] $destination_addresses = [$facts['networking']['ip'], $facts['networking']['ip6'],],
  String[1] $interface = $title,
  Integer[1024, 65000] $dport = Integer(regsubst($title, '^\D+(\d+)$', '\1')),
  String[1] $input_interface = $facts['networking']['primary'],
  Boolean $manage_firewall = true,
  Array[Stdlib::IP::Address] $source_addresses = [],
  Array[Hash[String,Variant[Stdlib::IP::Address::V4::CIDR,Stdlib::IP::Address::V6::CIDR]]] $addresses = [],
) {
  require wireguard

  if $manage_firewall {
    ferm::rule { "allow_wg_${interface}":
      action    => 'ACCEPT',
      chain     => 'INPUT',
      proto     => 'udp',
      dport     => $dport,
      interface => $input_interface,
      saddr     => $source_addresses,
      daddr     => $destination_addresses,
      notify    => Service['systemd-networkd'],
    }
  }
  exec { "generate ${interface} keys":
    command => "wg genkey | tee ${interface} | wg pubkey > ${interface}.pub",
    cwd     => $wireguard::config_directory,
    creates => "${wireguard::config_directory}/${interface}.pub",
    path    => '/usr/bin',
  }
  file { "${wireguard::config_directory}/${interface}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'systemd-network',
    mode    => '0640',
    require => Exec["generate ${interface} keys"],
  }
  file { "${wireguard::config_directory}/${interface}.pub":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Exec["generate ${interface} keys"],
  }
  # lint:ignore:strict_indent
  $netdev_config = @(EOT)
  <%- | $interface, $dport, $public_key, $endpoint | -%>
  # THIS FILE IS MANAGED BY PUPPET
  # based on https://dn42.dev/howto/wireguard
  [NetDev]
  Name=<%= $interface %>
  Kind=wireguard

  [WireGuard]
  PrivateKeyFile=/etc/wireguard/<%= $interface %>
  ListenPort=<%= $dport %>

  [WireGuardPeer]
  PublicKey=<%= $public_key %>
  <% if $endpoint { -%>
  Endpoint=<%= $endpoint %>
  <%} -%>
  AllowedIPs=fe80::/64
  AllowedIPs=fd00::/8
  AllowedIPs=0.0.0.0/0
  | EOT
  systemd::network { "${interface}.netdev":
    content         => inline_epp($netdev_config, { 'interface' => $interface, 'dport' => $dport, 'public_key' => $public_key, 'endpoint' => $endpoint }),
    restart_service => true,
    owner           => 'root',
    group           => 'systemd-network',
    mode            => '0440',
    require         => File["/etc/wireguard/${interface}"],
  }

  $network_config = @(EOT)
  <%- | $addresses, $interface | -%>
  # THIS FILE IS MANAGED BY PUPPET
  # based on https://dn42.dev/howto/wireguard
  [Match]
  Name=<%= $interface %>

  [Network]
  DHCP=no
  IPv6AcceptRA=false
  IPForward=yes

  # for networkd >= 244 KeepConfiguration stops networkd from
  # removing routes on this interface when restarting
  KeepConfiguration=yes

  <% $addresses.each |$address| { -%>
  [Address]
  <% $address.each |$key, $value| { -%>
  <%= $key %>=<%= $value %>
  <% } -%>

  <% } -%>
  | EOT
  # lint:endignore:strict_indent

  systemd::network { "${interface}.network":
    content         => inline_epp($network_config, { 'interface' => $interface, 'addresses' => $addresses }),
    restart_service => true,
    owner           => 'root',
    group           => 'systemd-network',
    mode            => '0440',
  }
}

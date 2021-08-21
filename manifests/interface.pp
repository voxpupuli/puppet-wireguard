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
# @param persistent_keepalive is set to 1 or greater, that's the interval in seconds wireguard sends a keepalive to the other peer(s). Useful if the sender is behind a NAT gateway or has a dynamic ip address
# @param description an optional string that will be added to the wireguard network interface
# @param mtu configure the MTU (maximum transision unit) for the wireguard tunnel. By default linux will figure this out. You might need to lower it if you're connection through a DSL line. MTU needs to be equal on both tunnel endpoints
#
# @author Tim Meusel <tim@bastelfreak.de>
#
# @see https://www.freedesktop.org/software/systemd/man/systemd.netdev.html#%5BWireGuardPeer%5D%20Section%20Options
#
# @example Peer with one node and setup dualstack firewall rules
#  wireguard::interface {'as2273':
#    source_addresses => ['2003:4f8:c17:4cf::1', '149.9.255.4'],
#    public_key       => 'BcxLll1BVxGQ5DeijroesjroiesjrjvX+EBhS4vcDn0R0=',
#    endpoint         => 'wg.example.com:53668',
#    addresses        => [{'Address' => '192.168.123.6/30',},{'Address' => 'fe80::beef:1/64'},],
#  }
#
# @example Peer with one node and setup dualstack firewall rules with peers in a different layer2
#  wireguard::interface {'as2273':
#    source_addresses => ['2003:4f8:c17:4cf::1', '149.9.255.4'],
#    public_key       => 'BcxLll1BVxGQ5DeijroesjroiesjrjvX+EBhS4vcDn0R0=',
#    endpoint         => 'wg.example.com:53668',
#    addresses        => [{'Address' => '192.168.218.87/32', 'Peer' => '172.20.53.97/32'}, {'Address' => 'fe80::ade1/64',},],
#  }
#
# @example Create a passive wireguard interface that listens for incoming connections. Useful when the other side has a dynamic IP / is behind NAT
#  wireguard::interface {'as2273':
#    source_addresses => ['2003:4f8:c17:4cf::1', '149.9.255.4'],
#    public_key       => 'BcxLll1BVxGQ5DeijroesjroiesjrjvX+EBhS4vcDn0R0=',
#    dport            => 53668,
#    addresses        => [{'Address' => '192.168.218.87/32', 'Peer' => '172.20.53.97/32'}, {'Address' => 'fe80::ade1/64',},],
#  }
#
# @example create a wireguard interface behind a DSL line with changing IP with lowered MTU
#  wireguard::interface {'as3668-2':
#    source_addresses      => ['144.76.249.220', '2a01:4f8:171:1152::12'],
#    public_key            => 'Tci/bHoPCjTpYv8bw17xQ7P4OdqzGpEN+NDueNjUvBA=',
#    endpoint              => 'router02.bastelfreak.org:1338',
#    dport                 => 1338,
#    input_interface       => $facts['networking']['primary'],
#    addresses             => [{'Address' => '169.254.0.10/32', 'Peer' =>'169.254.0.9/32'},{'Address' => 'fe80::beef:f/64'},],
#    destination_addresses => [],
#    persistent_keepalive  => 5,
#    mtu                   => 1412,
# }
#
define wireguard::interface (
  String[1] $public_key,
  Optional[String[1]] $endpoint = undef,
  Integer[0, 65535] $persistent_keepalive = 0,
  Array[Stdlib::IP::Address] $destination_addresses = [$facts['networking']['ip'], $facts['networking']['ip6'],],
  String[1] $interface = $title,
  Integer[1024, 65000] $dport = Integer(regsubst($title, '^\D+(\d+)$', '\1')),
  String[1] $input_interface = $facts['networking']['primary'],
  Boolean $manage_firewall = true,
  Array[Stdlib::IP::Address] $source_addresses = [],
  Array[Hash[String,Variant[Stdlib::IP::Address::V4::CIDR,Stdlib::IP::Address::V6::CIDR]]] $addresses = [],
  Optional[String[1]] $description = undef,
  Optional[Integer[1280, 9000]] $mtu = undef,
) {
  require wireguard

  if $manage_firewall {
    $daddr = empty($destination_addresses) ? {
      true    => undef,
      default => $destination_addresses,
    }
    ferm::rule { "allow_wg_${interface}":
      action    => 'ACCEPT',
      chain     => 'INPUT',
      proto     => 'udp',
      dport     => $dport,
      interface => $input_interface,
      saddr     => $source_addresses,
      daddr     => $daddr,
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
  <%- | $interface, $dport, $public_key, $endpoint, $description, $mtu | -%>
  # THIS FILE IS MANAGED BY PUPPET
  # based on https://dn42.dev/howto/wireguard
  [NetDev]
  Name=<%= $interface %>
  Kind=wireguard
  <% if $description { -%>
  Description=<%= $description %>
  <%} -%>
  <% if $mtu { -%>
  MTUBytes=<%= $mtu %>
  <%} -%>

  [WireGuard]
  PrivateKeyFile=/etc/wireguard/<%= $interface %>
  ListenPort=<%= $dport %>

  [WireGuardPeer]
  PublicKey=<%= $public_key %>
  <% if $endpoint { -%>
  Endpoint=<%= $endpoint %>
  <%} -%>
  PersistentKeepalive=<%= $persistent_keepalive %>
  AllowedIPs=fe80::/64
  AllowedIPs=fd00::/8
  AllowedIPs=0.0.0.0/0
  | EOT
  systemd::network { "${interface}.netdev":
    content         => inline_epp($netdev_config, { 'interface' => $interface, 'dport' => $dport, 'public_key' => $public_key, 'endpoint' => $endpoint, 'description' => $description, 'mtu' => $mtu }),
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

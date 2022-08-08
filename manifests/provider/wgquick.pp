#
# @summary manages a wireguard config file for wg-quick
#
# @param interface the name for the wg interface
# @param peers is an array of struct (Wireguard::Peers) for multiple peers
# @param dport destination for firewall rules / where our wg instance will listen on. defaults to the last digits from the title
# @param addresses different addresses for the systemd-networkd configuration
# @param preshared_key Define preshared key which should be used for this interface
#
class wireguard::provider::wgquick (
  String[1] $interface,
  Wireguard::Peers $peers = [],
  Integer[1024, 65000] $dport = Integer(regsubst($title, '^\D+(\d+)$', '\1')),
  Array[Hash[String,Variant[Stdlib::IP::Address::V4::CIDR,Stdlib::IP::Address::V6::CIDR]]] $addresses = [],
  Optional[String[1]] $preshared_key = undef,
) {
  $params = {
    'interface'     => $interface,
    'dport'         => $dport,
    'peers'         => $peers,
    'addresses'     => $addresses,
    'preshared_key' => $preshared_key,
  }

  file { "/etc/wireguard/${interface}.conf":
    content => epp("${module_name}/wireguard_conf.epp", $params),
    owner   => 'root',
    mode    => '0600',
  }
}

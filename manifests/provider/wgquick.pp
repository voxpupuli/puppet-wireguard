#
# @api private
#
define wireguard::provider::wgquick (
  String[1] $interface = $title,
  Wireguard::Peers $peers = [],
  Integer[1024, 65000] $dport = Integer(regsubst($title, '^\D+(\d+)$', '\1')),
  Array[Hash[String,Variant[Stdlib::IP::Address::V4::CIDR,Stdlib::IP::Address::V6::CIDR]]] $addresses = [],
  Optional[String[1]] $preshared_key = undef,
) {
  assert_private()
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

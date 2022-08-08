#
# @api private
#
define wireguard::provider::systemd (
  String[1] $interface = $title,
  Wireguard::Peers $peers = [],
  Integer[1024, 65000] $dport = Integer(regsubst($title, '^\D+(\d+)$', '\1')),
  Array[Hash[String,Variant[Stdlib::IP::Address::V4::CIDR,Stdlib::IP::Address::V6::CIDR]]] $addresses = [],
  Optional[String[1]] $description = undef,
  Optional[Integer[1280, 9000]] $mtu = undef,
  Array[Hash[String[1], Variant[String[1], Boolean]]] $routes = [],
  Optional[String[1]] $preshared_key = undef,
) {
  assert_private()
  systemd::network { "${interface}.netdev":
    content         => epp("${module_name}/netdev.epp", {
        'interface'     => $interface,
        'dport'         => $dport,
        'description'   => $description,
        'mtu'           => $mtu,
        'peers'         => $peers,
        'preshared_key' => $preshared_key,
    }),
    restart_service => true,
    owner           => 'root',
    group           => 'systemd-network',
    mode            => '0440',
    require         => File["/etc/wireguard/${interface}"],
  }

  $network_epp_params = {
    'interface' => $interface,
    'addresses' => $addresses,
    'routes'    => $routes,
  }

  systemd::network { "${interface}.network":
    content         => epp("${module_name}/network.epp", $network_epp_params),
    restart_service => true,
    owner           => 'root',
    group           => 'systemd-network',
    mode            => '0440',
  }
}

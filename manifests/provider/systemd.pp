#
# @summary manages a systemd wireguard interface
#
# @param interface the name for the wg interface
# @param peers is an array of struct (Wireguard::Peers) for multiple peers
# @param dport destination for firewall rules / where our wg instance will listen on. defaults to the last digits from the title
# @param addresses different addresses for the systemd-networkd configuration
# @param description an optional string that will be added to the wireguard network interface
# @param mtu configure the MTU (maximum transision unit) for the wireguard tunnel. By default linux will figure this out. You might need to lower it if you're connection through a DSL line. MTU needs to be equal on both tunnel endpoints
# @param routes different routes for the systemd-networkd configuration
# @param preshared_key Define preshared key which should be used for this interface
#
# @see https://www.freedesktop.org/software/systemd/man/systemd.netdev.html#%5BWireGuardPeer%5D%20Section%20Options
class wireguard::provider::systemd (
  String[1] $interface,
  Wireguard::Peers $peers = [],
  Integer[1024, 65000] $dport = Integer(regsubst($title, '^\D+(\d+)$', '\1')),
  Array[Hash[String,Variant[Stdlib::IP::Address::V4::CIDR,Stdlib::IP::Address::V6::CIDR]]] $addresses = [],
  Optional[String[1]] $description = undef,
  Optional[Integer[1280, 9000]] $mtu = undef,
  Array[Hash[String[1], Variant[String[1], Boolean]]] $routes = [],
  Optional[String[1]] $preshared_key = undef,
) {
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

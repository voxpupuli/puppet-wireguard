define wireguard::peer (
  String $interface,
  Optional[String] $description = undef,
  String $public_key,
  String $endpoint,
  Array[Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6]] $allowed_ips,
  Optional[String] $preshared_key = undef,
  Integer[0,65535] $persistent_keepalive = 0,
) {
  $peer_params = {
    'description'          => $description,
    'public_key'           => $public_key,
    'endpoint'             => $endpoint,
    'allowed_ips'          => $allowed_ips,
    'preshared_key'        => $preshared_key,
    'persistent_keepalive' => $persistent_keepalive,
  }

  concat::fragment { $name:
      order   => 20,
      target  => "/etc/wireguard/${interface}.conf",
      content => epp("${module_name}/wireguard_peer.epp", $peer_params),
  }
}

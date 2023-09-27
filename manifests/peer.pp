# @summary define a wireguard peer
#
# @param interface the title of the defined resource, will be used for the targetted wg interface
# @param description provide some identification details about the peer
# @param public_key base64 encoded pubkey from the remote peer
# @param endpoint fqdn:port or ip:port where we connect to
# @param allowed_ips different addresses that should be routed to this peer
# @param preshared_key Define preshared key for the remote peer
# @param persistent_keepalive is set to 1 or greater, that's the interval in seconds wireguard sends a keepalive to the other peer(s). Useful if the sender is behind a NAT gateway or has a dynamic ip address
#
define wireguard::peer (
  String[1] $interface,
  Optional[String[1]] $description = undef,
  String[1] $public_key,
  String[1] $endpoint,
  Array[Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6]] $allowed_ips,
  Optional[String[1]] $preshared_key = undef,
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

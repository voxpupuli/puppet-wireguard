# @summary Manage the wg quick components of a wireguard setup
# @api private
#
define wireguard::provider::wgquick (
  String[1] $interface = $title,
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $enable = true,
  Wireguard::Peers $peers = [],
  Integer[1024, 65000] $dport = Integer(regsubst($title, '^\D+(\d+)$', '\1')),
  Optional[Integer[0,4294967295]] $firewall_mark = undef,
  Array[Hash[String,Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6]]] $addresses = [],
  Array[String[1]] $preup_cmds = [],
  Array[String[1]] $postup_cmds = [],
  Array[String[1]] $predown_cmds = [],
  Array[String[1]] $postdown_cmds = [],
  Optional[Integer[1200, 9000]] $mtu = undef,
) {
  assert_private()
  $params = {
    'interface'     => $interface,
    'dport'         => $dport,
    'firewall_mark' => $firewall_mark,
    'mtu'           => $mtu,
    'addresses'     => $addresses,
    'preup_cmds'    => $preup_cmds,
    'postup_cmds'   => $postup_cmds,
    'predown_cmds'  => $predown_cmds,
    'postdown_cmds' => $postdown_cmds,
  }

  if ! empty($peers) {
    file { "/etc/wireguard/${interface}.conf":
      ensure  => $ensure,
      content => epp("${module_name}/wireguard_conf.epp", $params + { 'peers' => $peers }),
      owner   => 'root',
      mode    => '0600',
    }
  } else {
    concat { "/etc/wireguard/${interface}.conf":
      ensure => $ensure,
      owner  => 'root',
      mode   => '0600',
      notify => Service["wg-quick@${interface}"],
    }
    concat::fragment { "${interface}_head":
      order   => 10,
      target  => "/etc/wireguard/${interface}.conf",
      content => epp("${module_name}/wireguard_head.epp", $params),
    }
  }

  $svc_ensure = $ensure ? {
      present => 'running',
      absent  => 'stopped',
  }
  service { "wg-quick@${interface}":
    ensure => $svc_ensure,
    enable => $enable,
  }
}

#
# @summary manages the wireguard package
#
# @param manage_package if the package should be managed or not
# @param package_name the name of the package
# @param package_ensure the ensure state of the package
# @param config_directory the path to the wireguard directory
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class wireguard (
  Boolean $manage_package = true,
  String[1] $package_name = 'wireguard-tools',
  Enum['installed', 'latest', 'absent'] $package_ensure = 'installed',
  Stdlib::Absolutepath $config_directory = '/etc/wireguard',
){
  if $manage_package {
    package { 'wireguard-tools':
      ensure => 'installed',
    }
    Package[$package_name] -> File[$config_directory]
  }
  $_file_ensure = $package_ensure ? {
    'absent' => 'absent',
    default  => 'directory',
  }
  # created by the package, but with different permissions
  file { $config_directory:
    ensure  => $_file_ensure,
    owner   => 'root',
    mode    => '0750',
    group   => 'systemd-network',
  }
}

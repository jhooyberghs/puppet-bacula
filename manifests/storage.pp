# Class: bacula::storage
#
# Configures bacula storage daemon
#
class bacula::storage (
  $port                    = '9103',
  $listen_address          = $::ipaddress,
  $storage                 = $::fqdn, # storage here is not params::storage
  $password                = 'secret',
  $device                  = '/bacula',
  $device_manage           = false,
  $device_mode             = '0770',
  $device_name             = "${::fqdn}-device",
  $device_owner            = $bacula::params::bacula_user,
  $media_type              = 'File',
  $maxconcurjobs           = '5',
  $packages                = $bacula::params::bacula_storage_packages,
  $services                = $bacula::params::bacula_storage_services,
  $homedir                 = $bacula::params::homedir,
  $rundir                  = $bacula::params::rundir,
  $conf_dir                = $bacula::params::conf_dir,
  $director                = $bacula::params::director,
  $user                    = $bacula::params::bacula_user,
  $group                   = $bacula::params::bacula_group,
) inherits bacula::params {

  include bacula::common
  include bacula::ssl
  include bacula::virtual

  realize(Package[$packages])

  service { $services:
    ensure    => running,
    enable    => true,
    subscribe => File[$bacula::ssl::ssl_files],
    require   => Package[$packages],
  }

  concat::fragment { 'bacula-storage-header':
    order   => 00,
    target  => "${conf_dir}/bacula-sd.conf",
    content => template('bacula/bacula-sd-header.erb'),
  }

  bacula::storage::device { $device_name:
    device        => $device,
    media_type    => $media_type,
    password      => $password,
    storage       => $storage,
    concat_order  => '01',
    maxconcurjobs => $maxconcurjobs,
		device_manage => $device_manage,
    device_owner  => $device_owner,
    group         => $group,
    conf_dir      => $conf_dir,
    require       => Package[$packages],
  }

  concat::fragment { 'bacula-storage-dir':
    target  => "${conf_dir}/bacula-sd.conf",
    content => template('bacula/bacula-sd-dir.erb'),
  }

  bacula::messages { 'Standard-sd':
    daemon   => 'sd',
    director => "${director}-dir = all",
    syslog   => 'all, !skipped',
    append   => '"/var/log/bacula/bacula-sd.log" = all, !skipped',
  }

  # Realize the clause the director is exporting here so we can allow access to
  # the storage daemon Adds an entry to ${conf_dir}/bacula-sd.conf
  Concat::Fragment <<| tag == "bacula-storage-dir-${director}" |>>

  concat { "${conf_dir}/bacula-sd.conf":
    owner  => 'root',
    group  => $group,
    mode   => '0640',
    notify => Service[$services],
  }

}

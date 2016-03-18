# Define: bacula::storage::device
#

# This define creates a device declartion for the storage daemon.
#
define bacula::storage::device (
  $device,
  $storage,
  $password,
  $media_type     = 'File',
  $maxconcurjobs  = '5',
  $concat_order   = '05',
  $port           = '9103',
  $device_manage  = false,
  $device_owner   = $bacula::params::bacula_user,
  $group          = $bacula::params::bacula_group,
  $conf_dir       = $bacula::params::conf_dir,
) {

  include bacula::params

  concat::fragment { "bacula-storage-device-${name}":
    order   => $concat_order,
    target  => "${conf_dir}/bacula-sd.conf",
    content => template('bacula/bacula-sd-device.erb'),
  }

  if $device_manage {
    file { $device:
      ensure => directory,
      owner  => $device_owner,
      group  => $group,
      mode   => '0770',
    }
  }

  @@bacula::director::storage { $name:
    storage       => $storage,
    port          => $port,
    password      => $password,
    device_name   => $name,
    media_type    => $media_type,
    maxconcurjobs => $maxconcurjobs,
  }
}

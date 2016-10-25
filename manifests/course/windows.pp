# This is a wrapper class to include all the bits needed for Fundamentals
#
class classroom::course::windows (
  $offline      = $classroom::params::offline,
  $manage_yum   = $classroom::params::manage_yum,
  $time_servers = $classroom::params::time_servers,
) inherits classroom::params {
  # just wrap the classroom class
  class { 'classroom':
    offline      => $offline,
    role         => $role,
    manage_yum   => $manage_yum,
    time_servers => $time_servers,
  }

  if $::osfamily == 'Windows' {
    include classroom::windows
  }
}

# This is a wrapper class to include all the bits needed for Fundamentals
#
class classroom::course::windows (
  $offline   = $classroom::params::offline,
  $autosetup = $classroom::params::autosetup,
  $role      = $classroom::params::role,
) inherits classroom::params {

  # just wrap the classroom class
  class { 'classroom':
    offline   => $offline,
    autosetup => $autosetup,
    role      => $role,
  }

  if $::osfamily == 'Windows' {
    include classroom::windows
  }
}

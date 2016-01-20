# This is a wrapper class to include all the bits needed for Fundamentals
#
class classroom::course::windows (
  $offline   = $classroom::params::offline,
  $role      = $classroom::params::role,
) inherits classroom::params {

  # just wrap the classroom class
  class { 'classroom':
    offline   => $offline,
    role      => $role,
  }

  if $::osfamily == 'Windows' {
    include classroom::windows
  }
}

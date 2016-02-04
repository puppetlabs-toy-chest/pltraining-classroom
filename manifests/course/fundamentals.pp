# This is a wrapper class to include all the bits needed for Fundamentals
#
class classroom::course::fundamentals (
  $offline      = $classroom::params::offline,
  $manageyum    = $classroom::params::manageyum,
  $time_servers = $classroom::params::time_servers,
) inherits classroom::params {
  # just wrap the classroom class
  class { 'classroom':
    offline      => $offline,
    role         => $role,
    manageyum    => $manageyum,
    time_servers => $time_servers,
  }

  class { 'classroom::facts':
    coursename => 'fundamentals',
  }
}

# This is a wrapper class to include all the bits needed for Fundamentals
#
class classroom::course::fundamentals (
  $offline   = $classroom::params::offline,
  $autosetup = $classroom::params::autosetup,
  $role      = $classroom::params::role,
  $manageyum = $classroom::params::manageyum,
) inherits classroom::params {
  # just wrap the classroom class
  class { 'classroom':
    offline   => $offline,
    autosetup => $autosetup,
    role      => $role,
    manageyum => $manageyum,
  }

  class { 'classroom::facts':
    coursename => 'fundamentals',
  }
}

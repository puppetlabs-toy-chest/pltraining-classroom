# This class writes out some moderately interesting external facts. These are
# useful for demonstrating structured facts.
#
# Their existence also serves as a marker that initial provisioning has taken
# place, for the small handful of items that we only want to manage once.
#
class classroom::facts (
  $coursename,
  $role = $classroom::params::role,
) inherits classroom::params {

  $dot_d = "${classroom::params::factdir}/facts.d/"

  file { [ $classroom::params::factdir, $dot_d ]:
    ensure => directory,
  }

  file { "${dot_d}/puppetlabs.txt":
    ensure  => file,
    content => template('classroom/facts.txt.erb'),
  }
}

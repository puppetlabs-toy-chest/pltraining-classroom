# This class just manages all the git repositories on the master.
# If it is included, hiera will be configured with environment
# support, the environments directory will be managed and if
# teams are defined, their repositories will be managed.
class classroom::master::repositories {
  assert_private('This class should not be called directly')

  File {
    owner => 'root',
    group => 'root',
    mode  => '1777',
  }

  include git

  file { '/var/repositories':
    ensure => directory,
  }

  # configure Hiera environments for the master
  include classroom::master::hiera

  # if we've gotten to the Capstone and teams are defined, create our teams!
  $teams = hiera('teams', undef)
  if is_hash($teams) {
    $teamnames = keys($teams)

    # create each team. Pass in the full hash so that team can set its members
    classroom::master::team { $teamnames:
      teams => $teams,
    }
  }
}

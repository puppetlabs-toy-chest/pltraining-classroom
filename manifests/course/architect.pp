# This is a wrapper class to include all the bits needed for Architect
#
class classroom::course::architect (
  $offline      = $classroom::params::offline,
  $manage_yum   = $classroom::params::manage_yum,
  $time_servers = $classroom::params::time_servers,
) inherits classroom::params {
  # just wrap the classroom class
  class { 'classroom':
    offline       => $offline,
    role          => $role,
    manage_yum    => $manage_yum,
    time_servers  => $time_servers,
    manage_repos  => false,
  }

  if $role == 'master' {
    # Collect all hosts
    include classroom::agent::hosts

    # set up graphite/grafana on the classroom master
    include classroom::master::graphite

    # include metrics tools for labs & demos
    include classroom::master::metrics

    # serve our cached yum repositories so we can stop caching them for students
    include classroom::master::yum_server

    # Host docker registiry on master
    include classroom::master::docker_registry
  }
  elsif $role == 'agent' {
    # tools used in class
    include classroom::agent::r10k
    include classroom::master::reporting_tools

    # Collect all hosts
    include classroom::agent::hosts

    # include metrics tools for labs & demos
    include classroom::master::metrics

    # The student masters should export a balancermember
    include classroom::master::balancermember

    # The autoscaling seems to assume that you'll sync this out from the MoM
    include classroom::master::student_environment

    # Set up agent containers on student masters
    include classroom::containers

    if $manage_yum {
      # Use classroom master for yum cache
      include classroom::agent::yum_repos
    }
  }

  class { 'classroom::facts':
    coursename => 'architect',
  }
}

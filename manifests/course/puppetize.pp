# This is a wrapper class to include all the bits needed for Puppetizing infrastructure
class classroom::course::puppetize (
  $control_owner      = $classroom::params::control_owner,
  $offline            = $classroom::params::offline,
  $session_id         = $classroom::params::session_id,
  $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
  $use_gitea          = $classroom::params::use_gitea,
  $event_id           = undef,
  $event_pw           = undef,
  $version            = undef,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline            => $offline,
    use_gitea          => $use_gitea,
    jvm_tuning_profile => $jvm_tuning_profile,
    control_owner      => $control_owner,
    control_repo       => 'classroom-control-pi.git',
    event_id           => $event_id,
    event_pw           => $event_pw,
  }

  if $role == 'master' {
    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    include classroom::master::hiera

    class { 'classroom::facts':
      coursename => 'puppetizing',
    }

    class { 'classroom::master::showoff':
      course             => 'Puppetize',
      event_id           => $event_id,
      event_pw           => $event_pw,
      version            => $version,
    }

    file { '/usr/local/bin/validate_classification.rb':
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/classroom/validation/puppetize.rb',
    }
  }

  # All nodes
  include classroom::agent::git
}

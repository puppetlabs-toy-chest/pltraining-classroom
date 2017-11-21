# typing the parameters doesn't actually gain us anything, since the
# Console doesn't provide any hinting. Subclasses validate types.
class classroom::course::puppetize (
  $event_id           = undef,
  $event_pw           = undef,
  $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
  $offline            = $classroom::params::offline,
  $version            = undef,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
    control_repo       => 'classroom-control-pi.git',
    event_id           => $event_id,
    event_pw           => $event_pw,
    plugin_list        => flatten([$classroom::params::plugin_list, "Gitviz" ]),
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

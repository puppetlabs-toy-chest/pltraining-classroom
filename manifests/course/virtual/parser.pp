# typing the parameters doesn't actually gain us anything, since the
# Console doesn't provide any hinting. Subclasses validate types.
class classroom::course::virtual::parser (
  $event_id           = undef,
  $event_pw           = undef,
  $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
  $offline            = $classroom::params::offline,
  $version            = undef,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
    control_repo       => 'classroom-control-p4.git',
    event_id           => $event_id,
    event_pw           => $event_pw,
  }

  if $role == 'master' {
    class { 'classroom::facts':
      coursename => 'puppet4parser',
    }

    class { 'classroom::master::showoff':
      course             => 'Puppet4Parser',
      event_id           => $event_id,
      event_pw           => $event_pw,
      version            => $version,
    }
  }

}

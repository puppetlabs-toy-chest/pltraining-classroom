# typing the parameters doesn't actually gain us anything, since the
# Console doesn't provide any hinting. Subclasses validate types.
class classroom::course::virtual::fundamentals (
  $event_id           = undef,
  $event_pw           = undef,
  $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
  $offline            = $classroom::params::offline,
  $version            = undef,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
    control_repo       => 'classroom-control-vf.git',
    event_id           => $event_id,
    event_pw           => $event_pw,
  }

  if $role == 'master' {
    class { 'classroom::facts':
      coursename => 'fundamentals',
    }

    class { 'classroom::master::showoff':
      course             => 'Fundamentals',
      event_id           => $event_id,
      event_pw           => $event_pw,
      variant            => 'virtual',
      version            => $version,
    }
  }
}

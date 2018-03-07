class classroom::course::windows::addon (
  $offline            = $classroom::params::offline,
  $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
  $event_id           = undef,
  $event_pw           = undef,
  $version            = undef,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
    control_repo       => 'classroom-control-we.git',
    event_id           => $event_id,
    event_pw           => $event_pw,
  }

  if $role == 'master' {
    class { 'classroom::master::showoff':
      course             => 'WindowsEssentials',
      event_id           => $event_id,
      event_pw           => $event_pw,
      version            => $version,
      variant            => 'addon',
    }
  }

  if $::osfamily == 'Windows' {
    include classroom::windows
  }
}

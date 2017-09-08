class classroom::course::virtual::intro (
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
    control_repo       => 'classroom-control-intro.git',
    event_id           => $event_id,
    event_pw           => $event_pw,
  }

  if $role == 'master' {
    class { 'classroom::facts':
      coursename => 'intro',
    }

    class { 'classroom::master::showoff':
      course             => 'Intro',
      event_id           => $event_id,
      event_pw           => $event_pw,
      version            => $version,
    }
  }

  # Add hosts entries for app orch demo
  include classroom::agent::hosts

}

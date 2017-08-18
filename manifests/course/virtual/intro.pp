class classroom::course::virtual::intro (
  $session_id         = $classroom::params::session_id,
  $role               = $classroom::params::role,
  $offline            = $classroom::params::offline,
  $use_gitea          = $classroom::params::use_gitea,
  $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
  }

  if $role == 'master' {

    $base_plugin_list = [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "ShellUser" ]

    if $use_gitea {
      $plugin_list = flatten([$base_plugin_list, "Gitea" ])
    } else {
      $plugin_list = $base_plugin_list
    }

    # Classroom for Intro to puppet course
    class { 'puppetfactory':
      plugins    => $plugin_list,
      usersuffix => $classroom::params::usersuffix,
      session    => $session_id,
      privileged => false,
      modulepath => 'readwrite',
    }

  }
  # Add hosts entries for app orch demo
  include classroom::agent::hosts

}

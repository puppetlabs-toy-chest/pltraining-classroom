class classroom::course::virtual::fundamentals (
  $control_owner,
  $offline            = $classroom::params::offline,
  $session_id         = $classroom::params::session_id,
  $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
  $use_gitea          = $classroom::params::use_gitea,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
  }


  $gitserver = $use_gitea ? {
    true  => $classroom::params::gitserver['gitea'],
    false => $classroom::params::gitserver['github'],
  }


  if $role == 'master' {
    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    include classroom::master::dependencies::dashboard

    $base_plugin_list = [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "Dashboard", "CodeManager", "ShellUser" ]

    if $use_gitea {
      $plugin_list = flatten([$base_plugin_list, "Gitea" ])
    } else {
      $plugin_list = $base_plugin_list
    }

    class { 'puppetfactory':
      plugins        => $plugin_list,
      controlrepo    => 'classroom-control-vf.git',
      repomodel      => 'single',
      usersuffix     => $classroom::params::usersuffix,
      dashboard_path => "${showoff::root}/courseware/_files/tests",
      session        => $session_id,
      gitserver      => $gitserver,
      privileged     => false,
    }

    class { 'classroom::facts':
      coursename => 'fundamentals',
    }

    class { 'classroom::master::codemanager':
      control_owner => $control_owner,
      control_repo  => 'classroom-control-vf.git',
      use_gitea     => $use_gitea,
    }

  }
}

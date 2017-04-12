class classroom::course::virtual::fundamentals (
  $control_owner,
  $offline       = $classroom::params::offline,
  $session_id    = $classroom::params::session_id,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline => $offline,
  }

  if $role == 'master' {
    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    include classroom::master::dependencies::dashboard

    $base_plugin_list = [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "Dashboard", "CodeManager", "ShellUser" ]

    if $offline {
      $plugin_list = flatten([$base_plugin_list, "Gitea" ])
    } else {
      $plugin_list = $base_plugin_list
    }

    class { 'puppetfactory':
      plugins          => $plugin_list,
      controlrepo      => 'classroom-control-vf.git',
      repomodel        => 'single',
      usersuffix       => $classroom::params::usersuffix,
      dashboard_path   => "${showoff::root}/courseware/_files/tests",
      session          => $session_id,
      privileged       => false,
    }

    class { 'classroom::facts':
      coursename => 'fundamentals',
    }

    class { 'classroom::master::codemanager':
      control_owner => $control_owner,
      control_repo  => 'classroom-control-vf.git',
      offline       => $offline,
    }

  }
}

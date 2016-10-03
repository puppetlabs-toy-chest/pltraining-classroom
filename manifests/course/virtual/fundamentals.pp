class classroom::course::virtual::fundamentals (
  $offline    = $classroom::params::offline,
  $session_id = $classroom::params::session_id,
) inherits classroom::params {
  if $role == 'master' {
    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    include classroom::master::hiera
    include classroom::master::showoff
    include classroom::master::dependencies::dashboard

    class { 'puppetfactory':
      plugins          => [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "Dashboard", "CodeManager", "ShellUser" ],
      controlrepo      => 'classroom-control-vf.git',
      repomodel        => 'single',
      usersuffix       => $classroom::params::usersuffix,
      dashboard_path   => "${showoff::root}/courseware/_files/tests",
      session          => $session_id,
      privileged       => true,
    }

    class { 'classroom::facts':
      coursename => 'fundamentals',
    }

    class { 'classroom::master::codemanager':
      control_repo     => 'classroom-control-vf.git',
      offline          => $offline,
    }

  }
}

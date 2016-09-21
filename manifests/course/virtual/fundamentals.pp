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
      prefix           => true,
      map_environments => true,
      map_modulepath   => false,
      dashboard        => "${showoff::root}/courseware/_files/tests",
      session_id       => $session_id,
      gitlab_enabled   => false,
      privileged       => true,
    }

    class { 'classroom::facts':
      coursename => 'fundamentals',
    }

    class { 'classroom::master::codemanager':
      control_repo     => 'classroom-control-vf.git',
      per_student_repo => true,
      offline          => $offline,
    }

  }
}

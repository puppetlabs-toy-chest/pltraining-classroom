class classroom::course::virtual::intro (
  $session_id = $classroom::params::session_id,
  $role       = $classroom::params::role,
  $offline    = $classroom::params::offline,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline => $offline,
  }

  if $role == 'master' {

    # Classroom for Intro to puppet course
    class { 'puppetfactory':
      plugins    => [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "ShellUser" ],
      usersuffix => $classroom::params::usersuffix,
      session    => $session_id,
      privileged => false,
      modulepath => 'readwrite',
    }

  }
  # Add hosts entries for app orch demo
  include classroom::agent::hosts

}

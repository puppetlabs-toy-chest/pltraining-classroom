class classroom::course::virtual::intro (
  $session_id = $classroom::params::session_id,
  $role       = $classroom::params::role,
) inherits classroom::params {

  if $role == 'master' {

    include classroom::master::showoff

    # Classroom for Intro to puppet course
    class { 'puppetfactory':
      plugins          => [ "Certificates", "ConsoleUser", "Docker", "Logs", "ShellUser" ],
      usersuffix       => $classroom::params::usersuffix,
      session          => $session_id,
      privileged       => false,
    }

  }
  # Add hosts entries for app orch demo
  include classroom::agent::hosts

}

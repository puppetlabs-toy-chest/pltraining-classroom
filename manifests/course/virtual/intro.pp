class classroom::course::virtual::intro (
  $session_id = $classroom::params::session_id,
  $role       = $classroom::params::role,
) inherits classroom::params {

  if $role == 'master' {

    include classroom::master::showoff

    # Classroom for Intro to puppet course
    class { 'puppetfactory':
      plugins          => [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "ShellUser", "UserEnvironment" ],
      puppetcode       => '/root/puppetcode',
      modulepath       => 'readwrite',
      usersuffix       => 'puppetlabs.vm',
      session          => $session_id,
      privileged       => true,
    }

  }

}

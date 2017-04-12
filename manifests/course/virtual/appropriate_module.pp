class classroom::course::virtual::appropriate_module (
  $session_id = $classroom::params::session_id,
  $role       = $classroom::params::role,
  $offline    = $classroom::params::offline,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline => $offline,
  }

  if $role == 'master' {

    class { 'puppetfactory':
      plugins          => [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "ShellUser", "UserEnvironment" ],
      puppetcode       => $classroom::params::workdir,
      modulepath       => 'readwrite',
      usersuffix       => $classroom::params::usersuffix,
      session          => $session_id,
      privileged       => false,
    }

  }
}

class classroom::course::virtual::first_module (
  $session_id = $classroom::params::session_id,
  $role       = $classroom::params::role,
) inherits classroom::params {

  # Classroom for First Module
  if $role == 'master' {

    include classroom::master::showoff

    class { 'puppetfactory':
      # Put students' puppetcode directories somewhere obvious
      puppetcode       => '/var/puppetcode',
      map_environments => true,
      container_name   => 'centosagent',
      session_id       => $session_id,
      privileged       => true,
    }

  }
}

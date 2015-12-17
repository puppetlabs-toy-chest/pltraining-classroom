class classroom::course::virtual::first_module (
  $session_id = $classroom::params::session_id,
) inherits classroom::params {

  # Classroom for First Module
  class { 'puppetfactory':
    # Put students' puppetcode directories somewhere obvious
    puppetcode       => '/var/puppetcode',
    map_environments => true,
    container_name   => 'centosagent',
    session_id       => $session_id,
  }
}

class classroom::course::virtual::appropriate_module (
  $session_id = $classroom::params::session_id,
) inherits classroom::params {
  # Classroom for Appropriate Module Design course
  class { 'puppetfactory':
    # Put students' puppetcode directories somewhere obvious
    puppetcode       => '/root/puppetcode',
    map_environments => true,
    container_name   => 'centosagent',
    session_id       => $session_id,
  }
}

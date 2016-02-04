class classroom::course::virtual::intro (
  $session_id = $classroom::params::session_id,
) inherits classroom::params {

  # Classroom for Intro to puppet course
  class { 'puppetfactory':
    # Put students' puppetcode directories somewhere obvious
    puppetcode       => '/root/puppetcode',
    map_environments => true,
    container_name   => 'centosagent',
    session_id       => $session_id,
  }

  class { 'classroom::master::showoff':
    password => $session_id,
  }
}

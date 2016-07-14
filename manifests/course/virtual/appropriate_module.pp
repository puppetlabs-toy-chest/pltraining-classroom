class classroom::course::virtual::appropriate_module (
  $session_id = $classroom::params::session_id,
  $role = $classroom::params::role,
) inherits classroom::params {
  if $role == 'master' {

    include classroom::master::showoff

    # These are required by puppetfactory
    package { ['gcc','zlib', 'zlib-devel']:
      before => [ Package['puppetfactory'], Class['showoff'] ]
    }

    # Classroom for Appropriate Module Design course
    class { 'puppetfactory':
      # Put students' puppetcode directories somewhere obvious
      puppetcode       => '/root/puppetcode',
      map_environments => true,
      container_name   => 'centosagent',
      session_id       => $session_id,
    }

  }
}

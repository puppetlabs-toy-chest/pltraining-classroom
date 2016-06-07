class classroom::course::virtual::parser (
  $session_id = $classroom::params::session_id,
  $role       = $classroom::params::role,
) inherits classroom::params {

  if $role == 'master' {
    # Classroom for the parser course
    class { 'puppetfactory':
      # Put students' puppetcode directories somewhere less distracting
      puppetcode       => '/var/opt/puppetcode',
      map_environments => true,
      session_id       => $session_id,
    }
    class { 'classroom::master::showoff':
      password => $session_id,
    }
  }
  else {
    file { '/usr/local/bin/course_selector':
      ensure => present,
      mode   => '0755',
      source => '/usr/src/courseware-lms-content/scripts/course_selector.rb',
      require => Vcsrepo['/usr/src/courseware-lms-content'],
    }
    # Clone the courseware and copy example files to appropriate places
    vcsrepo { '/usr/src/courseware-lms-content':
      ensure   => present,
      provider => git,
      source   => 'https://github.com/puppetlabs/courseware-lms-content.git',
    }
  }

}

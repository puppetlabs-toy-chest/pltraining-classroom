class classroom::course::virtual::parser (
  $session_id = $classroom::params::session_id,
  $role       = $classroom::params::role,
) inherits classroom::params {
  include classroom::virtual

  if $role == 'master' {

    class { 'puppetfactory':
      plugins          => [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "ShellUser", "UserEnvironment" ],
      puppetcode       => '/var/puppetcode',
      modulepath       => 'readwrite',
      usersuffix       => $classroom::params::usersuffix,
      session          => $session_id,
      privileged       => false,
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

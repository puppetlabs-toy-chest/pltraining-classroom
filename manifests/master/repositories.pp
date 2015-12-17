class classroom::master::repositories {
  assert_private('This class should not be called directly')

  File {
    owner => 'root',
    group => 'root',
    mode  => '1777',
  }

  include git

  file { '/var/repositories':
    ensure => directory,
  }

}

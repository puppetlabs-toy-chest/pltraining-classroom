class classroom::agent::putty {

  if $::osfamily == 'windows' {
    package { 'putty':
      ensure => present,
      provider => 'chocolatey',
      require => Class['classroom::agent::chocolatey'],
    }
  }
  else {
    fail("putty supports only Windows, not ${::osfamily}")
  }

}

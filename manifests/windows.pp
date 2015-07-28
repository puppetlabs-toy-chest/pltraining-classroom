class classroom::windows {
  assert_private('This class should not be called directly')

  if $::osfamily == 'Windows' {
    user { 'Administrator':
      ensure => present,
      groups => ['Administrators'],
    }

    include classroom::windows::chocolatey
    include classroom::windows::geotrust
    include classroom::windows::password_policy
    include classroom::windows::disable_esc

    include userprefs::npp

    package { ['console2', 'putty']:
      ensure   => present,
      provider => 'chocolatey',
      require  => Class['classroom::windows::chocolatey'],
    }

    ini_setting { 'certname':
      ensure  => present,
      path    => "${classroom::confdir}/puppet.conf",
      section => 'main',
      setting => 'certname',
      value   => "${::hostname}.puppetlabs.vm",
    }

    # Symlink on the user desktop
    file { 'C:/Users/Administrator/Desktop/puppet_confdir':
      ensure => link,
      target => $classroom::confdir,
    }

    if $classroom::role == 'adserver' {
      include classroom::windows::adserver
    }
    else {
      Classroom::Windows::Dns_server <<||>>
    }
  }
  else {
    fail("This class only supports Windows, not ${::osfamily}")
  }
}
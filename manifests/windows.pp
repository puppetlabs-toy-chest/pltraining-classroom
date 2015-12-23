class classroom::windows {
  assert_private('This class should not be called directly')

  user { 'Administrator':
    ensure => present,
    groups => ['Administrators'],
  }

  include chocolatey
  include classroom::windows::geotrust
  include classroom::windows::password_policy
  include classroom::windows::disable_esc

  include userprefs::npp

  package { ['console2', 'putty', 'devbox-common.extension']:
    ensure   => present,
    provider => 'chocolatey',
    require  => Class['chocolatey'],
  }
 
  # Unzip package is broken on chocolatey so download directly
  exec { 'curl http://iweb.dl.sourceforge.net/project/gnuwin32/unzip/5.51-1/unzip-5.51-1.exe -Outfile C:/Windows/Temp/unzip.exe':
    provider => powershell,
    creates  => 'C:/Windows/Temp/unzip.exe',
    before   => Package['GnuWin32: UnZip version 5.51'],
  }

  package { 'GnuWin32: UnZip version 5.51':
    ensure          => present,
    provider        => 'windows',
    source          => 'C:/Windows/Temp/unzip.exe',
    install_options => '/VERYSILENT',
    require         => Package['devbox-common.extension'],
  }

  windows_env { 'PATH=C:\Program Files (x86)\GnuWin32\bin':
    require   => Package['GnuWin32: UnZip version 5.51'],
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

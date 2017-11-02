class classroom::windows {
  assert_private('This class should not be called directly')

  include classroom::windows::geotrust
  include classroom::windows::password_policy
  include classroom::windows::disable_esc
  include classroom::windows::alias

  include userprefs::npp

  package { ['console2', 'putty', 'unzip', 'devbox-common.extension']:
    ensure   => present,
    provider => 'chocolatey',
    require  => [ Class['chocolatey'], Package['chocolatey'] ],
  }

  package { 'chocolatey':
    ensure   => latest,
    provider => 'chocolatey',
    require  => Class['chocolatey'],
  }

  ini_setting { 'certname':
    ensure  => present,
    path    => "${classroom::params::confdir}/puppet.conf",
    section => 'main',
    setting => 'certname',
    value   => "${::hostname}.puppetlabs.vm",
  }

  # Symlink on the user desktop
  file { 'C:/Users/Administrator/Desktop/puppet_confdir':
    ensure => link,
    target => $classroom::params::confdir,
  }

  if $classroom::role == 'adserver' {
    class { 'classroom::windows::adserver':
      ad_domainname   => $classroom::ad_domainname,
      ad_dsrmpassword => $classroom::ad_dsrmpassword,
    }
    # Export AD server IP to be DNS server for agents
    @@classroom::windows::dns_server { 'primary_ip':
      ip => $::ipaddress,
    }
  }
  else {
    Classroom::Windows::Dns_server <<||>>
  }
}

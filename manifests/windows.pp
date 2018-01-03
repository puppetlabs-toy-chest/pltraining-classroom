class classroom::windows {
  assert_private('This class should not be called directly')

  require chocolatey

  include classroom::windows::geotrust
  include classroom::windows::password_policy
  include classroom::windows::disable_esc
  include classroom::windows::alias
  include classroom::windows::enable_rdp

  include userprefs::npp

  # Just a sanity check here. Some of the platforms we use don't have Admin by default.
  user { 'Administrator':
    ensure => present,
    groups => ['Administrators'],
  }

  windows_env { 'PATH=C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin': }

  # Not all choco packages we use have been updated with checksums
  chocolateyfeature { 'allowEmptyChecksums':
    ensure => enabled,
  }
  Chocolateyfeature['allowEmptyChecksums'] -> Package<| provider == 'chocolatey' |>

  package { ['console2', 'putty', 'unzip', 'devbox-common.extension']:
    ensure   => present,
    provider => 'chocolatey',
    require  => [ Class['chocolatey'], Package['chocolatey'] ],
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

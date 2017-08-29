class classroom::windows {
  assert_private('This class should not be called directly')

  user { 'Administrator':
    ensure => present,
    groups => ['Administrators'],
  }

  class {'chocolatey':
    chocolatey_download_url => 'https://chocolatey.org/api/v2/package/chocolatey/0.10.3',
  }

  chocolateyfeature { 'allowEmptyChecksums':
    ensure => enabled,
  }
  Chocolateyfeature['allowEmptyChecksums'] -> Package<| provider == 'chocolatey' |>

  include classroom::windows::geotrust
  include classroom::windows::password_policy
  include classroom::windows::disable_esc
  include classroom::windows::alias

  # TODO: remove this abomination once the PE stack is updated
  include classroom::windows::rubygems_update

  windows_env { 'PATH=C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin' : }

  include userprefs::npp

  package { ['console2', 'putty', 'unzip', 'devbox-common.extension']:
    ensure   => present,
    provider => 'chocolatey',
    require  => Class['chocolatey'],
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
    class { 'classroom::windows::adserver':
      ad_domainname   => $classroom::ad_domainname,
      ad_dsrmpassword => $classroom::ad_dsrmpassword,
    }
    # Export AD server IP to be DNS server for agents
    @@classroom::windows::dns_server { 'primary_ip':
      ip => $::ipaddress,
    }
    Dsc::Dsc_xdnsrecord <<||>>
  }
  else {
    Classroom::Windows::Dns_server <<||>>
  }
}

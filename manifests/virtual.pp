# common configuration for all virtual classes
class classroom::virtual (
  Boolean $offline = false,
) {
  assert_private('This class should not be called directly')

  if $classroom::params::role == 'master' {
    include classroom::master::dependencies::rubygems
    include classroom::master::showoff
    include classroom::master::hiera

    # Configure performance logging
    include classroom::master::perf_logging

    if $offline {
      include classroom::master::gitea
    }
  } elsif $classroom::params::role == 'proxy' {
    include classroom::proxy
  } else {
    # if we ever have universal classification for virtual agents, it will go here
    include classroom::agent::hiera
    include classroom::agent::packages
    include classroom::agent::postfix_ipv4
  }

  if $::osfamily == 'windows' {
    # TODO: copied from classroom::windows; we should refactor both classes for reusability
    user { 'Administrator':
      ensure => present,
      groups => ['Administrators'],
    }

    chocolateyfeature { 'allowEmptyChecksums':
      ensure => enabled,
    }
    Chocolateyfeature['allowEmptyChecksums'] -> Package<| provider == 'chocolatey' |>

    # Windows Agents
    class {'chocolatey':
      chocolatey_download_url => 'https://chocolatey.org/api/v2/package/chocolatey/0.10.3',
    }

    include classroom::windows::disable_esc
    include classroom::windows::enable_rdp
    include classroom::windows::geotrust
    include classroom::windows::rubygems_update
    windows_env { 'PATH=C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin': }
  }


  # fix augeas lens until it's updated in PE
  include classroom::agent::augeas
}

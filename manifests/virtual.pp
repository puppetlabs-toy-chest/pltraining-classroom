# common configuration for all virtual classes
class classroom::virtual {
  assert_private('This class should not be called directly')

  if $classroom::params::role == 'master' {
    include classroom::master::dependencies::rubygems
    include classroom::master::showoff

    # Configure performance logging
    include classroom::master::perf_logging
  } else {
    # if we ever have universal classification for virtual agents, it will go here

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
    include chocolatey
    include classroom::windows::disable_esc
    include classroom::windows::enable_rdp
    include classroom::windows::geotrust
    include classroom::windows::rubygems_update
    windows_env { 'PATH=C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin': }
  }

}
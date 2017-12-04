# common configuration for all virtual classes
class classroom::virtual (
  String                                  $control_repo,
  Optional[Pattern[/\A(?:\w*-)+(\w*)\Z/]] $event_id           = undef,
  Optional[String]                        $event_pw           = undef,
  Variant[Enum['reduced'], Boolean]       $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
  Boolean                                 $offline            = $classroom::params::offline,
  Array                                   $plugin_list        = $classroom::params::plugin_list,
) inherits classroom::params {
  assert_private('This class should not be called directly')

  if $classroom::params::role == 'master' {
    include showoff
    include classroom::master::dependencies::rubygems
    include classroom::master::dependencies::dashboard

    # Configure Hiera and install a Hiera data file to tune PE
    class { 'classroom::master::tuning':
      jvm_tuning_profile => $jvm_tuning_profile,
    }

    # make sure we have a deployment user
    include classroom::master::deployer

    # Configure performance logging
    include classroom::master::perf_logging

    # Set up gitea server
    include classroom::master::gitea

    $session_id = pick($event_pw, regsubst(String($event_id), '^(?:\w*-)+(\w*)$', '\1'), $classroom::params::session_id)

    class { 'puppetfactory':
      controlrepo      => $control_repo,
      plugins          => $plugin_list,
      gitserver        => $classroom::params::gitserver,
      repomodel        => $classroom::params::repo_model,
      usersuffix       => $classroom::params::usersuffix,
      dashboard_path   => "${showoff::root}/courseware/_files/tests",
      session          => $session_id,
      master           => $fqdn,
      privileged       => false,
    }

    class { 'classroom::master::codemanager':
      control_repo => $control_repo,
    }

  } elsif $classroom::params::role == 'proxy' {
    include classroom::proxy

  } else {
    # ensure all nodes have this user, since it's used for file ownership in places
    user { 'pe-puppet':
      ensure => present,
    }

    # if we ever have universal classification for virtual agents, it will go here
    include classroom::agent::hiera
    include classroom::agent::packages
    include classroom::agent::rubygems

    unless $osfamily == 'windows' {
      include classroom::agent::postfix_ipv4

      # enable the local yum cache configured by puppetfactory
      yumrepo { 'local':
        ensure   => 'present',
        baseurl  => 'file:///var/yum/mirror',
        enabled  => '1',
        gpgcheck => '0',
        priority => '1',
      }

    }
  }

  # configure gem installs
  class { 'classroom::gemrc':
    offline => $offline,
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
    windows_env { 'PATH=C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin': }
  }

  # fix augeas lens until it's updated in PE
  include classroom::agent::augeas
}

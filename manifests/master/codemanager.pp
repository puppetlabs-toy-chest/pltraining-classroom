# Configuration for PE code manager to avoid chicken -> egg -> chicken
class classroom::master::codemanager (
  $control_repo     = undef,
  $repo_model       = $classroom::params::repo_model,
  $offline          = $classroom::params::offline,
  $control_owner    = $classroom::params::control_owner,
) inherits classroom::params {
  assert_private('This class should not be called directly')

  if $control_repo {
    $hieradata = "${classroom::params::confdir}/hieradata"
    $gitserver = $offline ? {
      true  => $classroom::params::gitserver['offline'],
      false => $classroom::params::gitserver['online'],
    }

    pe_hocon_setting { 'enable code manager':
      ensure  => present,
      path    => '/etc/puppetlabs/enterprise/conf.d/common.conf',
      setting => '"puppet_enterprise::profile::master::code_manager_auto_configure"',
      value   => true,
    }

    pe_hocon_setting { 'production control repo':
      ensure  => present,
      path    => '/etc/puppetlabs/enterprise/conf.d/common.conf',
      setting => '"puppet_enterprise::master::code_manager::sources".main',
      value   => { 'remote' => "${gitserver}/${control_owner}/${control_repo}" },
    }

    $replace = $repo_model ? {
      'single'  => true,
      'peruser' => false, # the puppetfactory hook must be able to update this list!
    }
    # duplicated in a hiera datasource. because reasons.
    file { "${hieradata}/sources.yaml":
      ensure  => file,
      replace => $replace,
      content => epp('classroom/hiera/data/sources.yaml.epp', {
                                        'gitserver'     => $gitserver,
                                        'control_owner' => $control_owner,
                                        'control_repo'  => $control_repo }),
    }

  }

  if(versioncmp($::pe_server_version, '2016.1.1') > 0) {
    # <Workaround for PE-15399>
    pe_hocon_setting { 'file-sync.client.stream-file-threshold':
      path    => '/etc/puppetlabs/puppetserver/conf.d/file-sync.conf',
      setting => 'file-sync.client.stream-file-threshold',
      value   => 512,
    }
    # </Workaround>
  }

}

# Configuration for PE code manager to avoid chicken -> egg -> chicken
class classroom::master::codemanager (
  $control_repo     = undef,
  $repo_model       = $classroom::params::repo_model,
  $use_gitea        = $classroom::params::use_gitea,
  $control_owner    = $classroom::params::control_owner,
) inherits classroom::params {
  assert_private('This class should not be called directly')

  if $control_repo {
    $hieradata = "${classroom::params::confdir}/hieradata"
    $gitserver = $use_gitea ? {
      true  => $classroom::params::gitserver['gitea'],
      false => $classroom::params::gitserver['github'],
    }

    if ($use_gitea) and ($control_owner != $classroom::params::control_owner) {
      fail('Control owner cannot be set when using gitea') 
    }
    if ($use_gitea == false) and ($control_owner == $classroom::params::control_owner) {
      fail('control_owner is a required parameter for trainings using github')
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

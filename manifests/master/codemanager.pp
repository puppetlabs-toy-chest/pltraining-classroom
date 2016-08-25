class classroom::master::codemanager (
  $control_repo     = undef,
  $offline          = $classroom::params::offline,
  $control_owner    = $classroom::params::control_owner,
  $per_student_repo = $classroom::params::per_student_repo,
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
      value   => { 'remote' => "${gitserver}/${control_repo}" },
    }

    # duplicated in a hiera datasource. because reasons.
    file { "${hieradata}/sources.yaml":
      ensure  => file,
      replace => false, # the puppetfactory hook must be able to update this list!
      content => epp('classroom/hiera/data/sources.yaml.epp', {
                                        'gitserver'     => $gitserver,
                                        'control_owner' => $control_owner,
                                        'control_repo'  => $control_repo }),
    }

    if $per_student_repo {
      $hooks = ['/etc/puppetfactory/hooks/create',
                '/etc/puppetfactory/hooks/delete',
               ]

      dirtree { $hooks:
        ensure => present,
      }

      # install into system ruby too
      package { 'hocon':
        ensure   => present,
        provider => gem,
      }

      file { '/etc/puppetfactory/hooks/create/cm_create_user.rb':
        ensure => file,
        mode   => '0755',
        content => epp('classroom/cm_env.rb.epp',{ 'gitserver' => $gitserver, 'control_repo' => $control_repo }),
      }

      # this looks wonky, but the script uses its name to determine mode of operation
      file { '/etc/puppetfactory/hooks/delete/cm_delete_user.rb':
        ensure => link,
        target => '/etc/puppetfactory/hooks/create/cm_create_user.rb',
      }
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

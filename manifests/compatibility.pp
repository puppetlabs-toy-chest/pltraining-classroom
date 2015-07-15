# Set up some goofy symlinks so this module will apply cleanly on PE 3.x
class classroom::compatibility {
  assert_private('This class should not be called directly')

  if versioncmp($::pe_server_version, '2015.0') < 0 {

    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    $directories = [
      '/etc/puppetlabs/code',
      '/opt/puppetlabs',
      '/opt/puppetlabs/puppet',
    ]

    file { $directories:
      ensure => directory,
    }

    file { '/opt/puppetlabs/puppet/bin':
      ensure  => link,
      target  => '/opt/puppet/bin',
    }

    # links from the new codedir
    file { '/etc/puppetlabs/code/environments':
      ensure  => link,
      target  => '/etc/puppetlabs/puppet/environments',
    }

    file { '/etc/puppetlabs/code/modules':
      ensure  => link,
      target  => '/etc/puppetlabs/puppet/modules',
    }

    # must link these from the old confdir because we're writing content into the target
    file { '/etc/puppetlabs/puppet/hiera.yaml':
      ensure  => link,
      force   => true,
      target  => '/etc/puppetlabs/code/hiera.yaml',
    }

    file { '/etc/puppetlabs/puppet/hieradata':
      ensure  => link,
      force   => true,
      target  => '/etc/puppetlabs/code/hieradata',
    }

  }

}
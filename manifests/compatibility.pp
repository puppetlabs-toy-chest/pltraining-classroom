# Set up some goofy symlinks so this module will apply cleanly on PE 3.x
class classroom::compatibility {
  assert_private('This class should not be called directly')

  unless $::aio_agent_version {

    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    file { [ '/opt/puppetlabs', '/opt/puppetlabs/puppet' ]:
      ensure => directory,
    }

    file { '/opt/puppetlabs/puppet/bin':
      ensure => link,
      target => '/opt/puppet/bin',
    }

    # links the new codedir
    file { '/etc/puppetlabs/code':
      ensure => link,
      target => '/etc/puppetlabs/puppet',
    }

  }

}

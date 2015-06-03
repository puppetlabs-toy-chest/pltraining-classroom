# Make sure that Hiera is configured for the master so that we
# enabling the use of Hiera within student environments.
#
#
class classroom::master::hiera {

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  file { '/etc/puppetlabs/puppet/hieradata':
    ensure => directory,
  }

  file { '/etc/puppetlabs/puppet/hieradata/defaults.yaml':
    ensure  => file,
    source  => 'puppet:///modules/classroom/hiera/data/defaults.yaml',
    replace => false,
  }

  # place the environments link in place only on the master
  file { '/etc/puppetlabs/puppet/hieradata/environments':
    ensure => link,
    target => '/etc/puppetlabs/puppet/environments',
  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure => file,
    source => 'puppet:///modules/classroom/hiera/hiera.master.yaml',
  }

}

class classroom::agent::rubygems (
  Boolean $offline = false,
) {
  if $offline {
    # When offline, install gems from the /var/cache/rubygems directory
    exec { 'install rspec-puppet gems':
      command => 'gem install -l rspec-puppet-2.3.0.gem',
      cwd     => '/var/cache/rubygems/gems',
      path    => '/opt/puppetlabs/puppet/bin:/bin',
      unless  => 'gem list rspec-puppet | grep -q ^rspec-puppet',
    }

    exec { 'install psh gems':
      command => 'gem install -l puppetlabs_spec_helper-1.0.1.gem',
      cwd     => '/var/cache/rubygems/gems',
      path    => '/opt/puppetlabs/puppet/bin:/bin',
      unless  => 'gem list puppetlabs_spec_helper | grep -q ^puppetlabs_spec_helper',
    }

    # Install serverspec with system gem instead of Puppet gem
    exec { 'install serverspec gems':
      command => 'gem install -l serverspec-2.27.0.gem',
      cwd     => '/var/cache/rubygems/gems',
      path    => '/bin',
      unless  => 'gem list serverspec | grep -q ^serverspec',
    }
  }
  else {
    # When online, simple package resources work fine
    package { [ 'rspec-puppet', 'puppetlabs_spec_helper' ]:
      ensure   => present,
      provider => 'puppet_gem',
    }

    package { 'serverspec':
      ensure   => present,
      provider => 'gem',
    }
  }
}

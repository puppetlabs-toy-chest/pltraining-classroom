class classroom::agent::rubygems {
  assert_private('This class should not be called directly')

  # Required net-telnet version to not require ruby >= 2.3.0
  package{'net-telnet':
    ensure   => '0.1.1',
    provider => gem,
  }

  # Required specinfra version to not require ruby >= 2.2.6
  package { 'specinfra':
    ensure   => '2.74.0',
    provider => gem,
    require  => Package['net-telnet'],
  }

  package { ['serverspec', 'rake']:
    ensure   => present,
    provider => 'gem',
    require  => Package['specinfra'],
  }

  package { [ 'rspec-puppet', 'puppetlabs_spec_helper' ]:
    ensure   => present,
    provider => 'puppet_gem',

  }

}

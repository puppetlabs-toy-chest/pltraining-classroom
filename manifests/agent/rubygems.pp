class classroom::agent::rubygems {
  assert_private('This class should not be called directly')

  # Required specinfra version to not require ruby >= 2.2.6
  package { 'specinfra':
    ensure   => '2.74.0',
    provider => gem,
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

class classroom::agent::rubygems {
  assert_private('This class should not be called directly')

  package { [ 'rspec-puppet', 'puppetlabs_spec_helper' ]:
    ensure   => present,
    provider => 'puppet_gem',
  }

  package { ['serverspec', 'rake']:
    ensure   => present,
    provider => 'gem',
  }
}

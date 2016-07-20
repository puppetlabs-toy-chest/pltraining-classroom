class classroom::master::dependencies::dashboard {
  assert_private('This class should not be called directly')

  package { ['serverspec', 'puppetlabs_spec_helper']:
    ensure   => present,
    provider => gem,
    require  => Package['puppet'],
  }

  # lol, this is great. The puppet gem is a requirement, but it conflicts with
  # the Puppet Enterprise installation.
  package { 'puppet':
    ensure          => present,
    provider        => gem,
    install_options => { '--bindir' => '/tmp' },
  }

}

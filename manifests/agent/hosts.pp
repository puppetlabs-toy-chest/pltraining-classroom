class classroom::agent::hosts {
  assert_private('This class should not be called directly')

  @@host { $::fqdn:
    ensure       => 'present',
    host_aliases => [$::hostname],
    ip           => $::ipaddress,
    tag          => ['classroom','master'],
  }

  Host <<| tag == 'classroom' |>>
}

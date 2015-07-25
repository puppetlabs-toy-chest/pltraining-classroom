class classroom::master::balancermember {
  assert_private('This class should not be called directly')

  @@haproxy::balancermember { "puppet_${::fqdn}":
    listening_service => 'puppet00',
    server_names      => $::hostname,
    ipaddresses       => $::ipaddress,
    ports             => '8140',
    options           => 'check',
  }
}

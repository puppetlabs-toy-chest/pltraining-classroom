class classroom::proxy {
  assert_private('This class should not be called directly')

  include '::haproxy'
  include classroom::agent::time

  haproxy::listen { 'puppet00':
    ipaddress => $::ipaddress,
    ports     => '8140',
    options   => {
      'mode'  => 'tcp',
    },
  }

  haproxy::listen { 'wordpress00':
    ipaddress => $::ipaddress,
    ports     => '80',
    options   => {
      'mode'  => 'http',
    },
  }

  haproxy::listen { 'stats':
    ipaddress => $::ipaddress,
    ports     => '9090',
    options   => {
      'mode'  => 'http',
      'stats' => ['uri /', 'auth puppet:puppet']
      },
  }

  Host <<| tag == 'classroom' |>>

  @@host { $::fqdn:
    ensure       => present,
    host_aliases => [$::hostname, 'irc.puppetlabs.vm'],
    ip           => $::ipaddress,
    tag          => 'classroom'
  }
}

class classroom::agent::postfix_ipv4 {
  package {'postfix':
    ensure => present,
  }
  # Set postfix main.cf to only use ipv4
  augeas { 'postfix inet_protocols':
    context => '/files/etc/postfix/main.cf',
    changes => [
      'set /files/etc/postfix/main.cf/inet_protocols ipv4'
    ],
  }
}

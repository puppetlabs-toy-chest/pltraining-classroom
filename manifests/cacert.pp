class classroom::cacert {
  assert_private('This class should not be called directly')

  file { '/etc/pki/ca-trust/source/anchors/classroom.crt':
    ensure => file,
    source => "${classroom::confdir}/ssl/certs/ca.pem",
    notify => Exec['trust classroom ca'],
  }

  exec { 'trust classroom ca':
    command     => '/usr/bin/update-ca-trust extract',
    onlyif      => '/usr/bin/update-ca-trust enable',
    refreshonly => true,
  }
}

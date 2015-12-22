class classroom::cacert {
  assert_private('This class should not be called directly')

  $classroom_cert = '/etc/pki/ca-trust/source/anchors/classroom.crt'

  if $::osfamily != 'windows' {
    file { $classroom_cert:
      ensure => file,
      source => "${classroom::confdir}/ssl/certs/ca.pem",
      notify => Exec['trust classroom ca'],
    }

    if versioncmp($::aio_agent_verstion, '1.3.2') >= 0 {  
      exec { 'trust classroom ca':
        command     => "cat ${classroom_cert} >> /opt/puppetlabs/puppet/ssl/cert.pem ",
        path        => '/bin/',
        refreshonly => true,
      }
    } else {
      exec { 'trust classroom ca':
        command     => '/usr/bin/update-ca-trust extract',
        onlyif      => '/usr/bin/update-ca-trust enable',
        refreshonly => true,
      }
    }
  }
  else {
    # We don't need this for windows yet.
  }
}

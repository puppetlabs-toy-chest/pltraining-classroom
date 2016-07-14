# Performance logging for the classroom.
class classroom::master::perf_logging {
  assert_private('This class should not be called directly')

  package { ['sysstat', 'tcpdump']:
    ensure => present,
  }

  package { 'aws-sdk':
    ensure   => present,
    provider => gem,
  }

  file { '/usr/local/bin/classroom_performance':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/classroom/classroom_performance',
  }

  cron { 'snapshot performance':
    ensure  => present,
    command => '/usr/local/bin/classroom_performance snapshot',
    minute  => ['12', '42'],
  }

}

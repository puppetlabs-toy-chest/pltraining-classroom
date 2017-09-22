# Performance logging for the classroom.
class classroom::master::perf_logging {
  assert_private('This class should not be called directly')

  package { ['sysstat', 'tcpdump']:
    ensure => present,
  }

  cron { 'snapshot performance':
    ensure  => present,
    command => '/usr/local/bin/classroom performance snapshot',
    minute  => ['12', '42'],
  }

}

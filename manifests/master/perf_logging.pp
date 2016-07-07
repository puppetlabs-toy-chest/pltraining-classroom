# Performance logging for the classroom.
class classroom::master::perf_logging {
  assert_private('This class should not be called directly')

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

  # upload report if more than 2.5 days have passed.
  cron { 'submit performance report':
    ensure  => present,
    command => '/usr/local/bin/classroom_performance report',
    minute  => ['47'],
  }

}

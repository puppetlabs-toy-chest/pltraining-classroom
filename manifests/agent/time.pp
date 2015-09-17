# Ensures that all agents are synced to the classroom master via a cron task
#
# Warning: Do not use in production - this is a hack specifically for
# puppetlabs training courses
#
# Use:
#   Classify all agent nodes
#
class classroom::agent::time {
  assert_private('This class should not be called directly')

  if $::osfamily == 'windows' {
    service { 'W32Time':
      ensure => running,
      enable => true,
    }
    # For information on setting w32time registry keys, see:
    # http://blogs.msdn.com/b/w32time/archive/2008/02/26/
    #   configuring-the-time-service-ntpserver-and-specialpollinterval.aspx
    registry::value { 'ntp server':
      key     => 'HKLM\SYSTEM\ControlSet001\Services\W32Time\Parameters',
      value   => 'NtpServer',
      type    => string,
      data    => 'master.puppetlabs.vm,0x01',
      notify  => Exec['w32tm config update'],
    }
    registry::value { 'ntp poll interval':
      key     => 'HKLM\SYSTEM\ControlSet001\Services\W32Time\TimeProviders\NtpClient',
      value   => 'SpecialPollInterval',
      type    => dword,
      data    => '300',
      notify  => Exec['w32tm config update'],
    }
    exec { 'w32tm config update':
      command     => 'w32tm /config /update',
      path        => $::path,
      require     => Service['W32Time'],
      refreshonly => true,
    }
  }
  else {
    $service_name = $::osfamily ? {
      'debian' => 'ntp',
      default  => 'ntpd',
    }
    package { 'ntpdate':
      ensure => present,
    } ->
    service { $service_name:
      ensure => stopped,
    }
    # For agents, *always* stay true to the time on on the master
    cron { 'synctime':
      command => "/usr/sbin/ntpdate -s ${::servername}",
      minute  => '*/5',
    }
  }
}

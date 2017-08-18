# This assumes that the gitea rpm and dependencies have been cached by the
# pltraining-bootstrap module.
class classroom::master::gitea {

  # Use public IP for ec2 hosted trainings
  $gitea_address = $facts['ec2_metadata'] ? {
        undef   => $ipaddress,
        default => $facts['ec2_metadata']['public-ipv4']
  }

  package { 'gitea':
    ensure => present,
  }

  ini_setting { "database user":
    ensure  => present,
    path    => '/home/git/go/bin/custom/conf/app.ini',
    section => 'database',
    setting => 'user',
    value   => 'root',
    require => Package['gitea'],
    notify  => Service['gitea'],
  }

  ini_setting { "ssh domain":
    ensure  => present,
    path    => '/home/git/go/bin/custom/conf/app.ini',
    section => 'server',
    setting => 'SSH_DOMAIN',
    value => $gitea_address,
    require => Package['gitea'],
    notify  => Service['gitea'],
  }

  ini_setting { "domain":
    ensure  => present,
    path    => '/home/git/go/bin/custom/conf/app.ini',
    section => 'server',
    setting => 'DOMAIN',
    value => $gitea_address,
    require => Package['gitea'],
    notify  => Service['gitea'],
  }
  ini_setting { "root url":
    ensure  => present,
    path    => '/home/git/go/bin/custom/conf/app.ini',
    section => 'server',
    setting => 'ROOT_URL',
    value => "http://${gitea_address}:3000/",
    require => Package['gitea'],
    notify  => Service['gitea'],
  }

  service { 'gitea':
    ensure  => 'running',
    enable  => true,
  }
}

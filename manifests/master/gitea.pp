# This assumes that the gitea rpm and dependencies have been cached by the
# pltraining-bootstrap module.
class classroom::master::gitea {
  package { 'gitea':
    name     => 'gitea',
    provider => 'rpm',
    source   => '/usr/src/rpm_cache/gitea.rpm',
    before   => File['/home/git/go/bin/custom/conf/app.ini'],
  }
  package { 'golang':
    ensure => present,
    before => Package['gitea'],
  }

  file { '/home/git/go/bin/custom/conf/app.ini':
    ensure  => file,
    owner   => 'git',
    group   => 'git',
    mode    => '0644',
    source  => 'puppet:///modules/classroom/app.ini',
    notify  => Service['gitea'],
  }

  service { 'gitea':
    ensure  => 'running',
  }
}

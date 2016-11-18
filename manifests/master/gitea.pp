# This assumes that the gitea rpm and dependencies have been cached by the
# pltraining-bootstrap module.
class classroom::master::gitea {
  package { 'gitea':
    name     => 'gitea',
    provider => 'rpm',
    source   => '/usr/src/rpm_cache/gitea.rpm',
    before   => File['/home/git/go/bin/custom/conf/app.ini'],
    require  => Package['golang-bin', 'golang-src', 'golang'],
  }

  package { ['golang-bin', 'golang-src', 'golang']:
    ensure => present,
  }

  file { '/home/git/go/bin/custom/conf/app.ini':
    ensure  => file,
    owner   => 'git',
    group   => 'git',
    mode    => '0644',
    content => template('classroom/app.ini.erb'),
    notify  => Service['gitea'],
  }

  service { 'gitea':
    ensure  => 'running',
  }
}

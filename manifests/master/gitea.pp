# This assumes that the gitea rpm and dependencies have been cached by the
# pltraining-bootstrap module.
class classroom::master::gitea {
  service { 'gitea':
    ensure  => 'running',
    require => Package['gitea'],
  }
  package { 'gitea':
    source => "/usr/src/rpm_cache/gitea.rpm",
  }
}

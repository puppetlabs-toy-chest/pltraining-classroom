class classroom::master::sudoers {
  assert_private('This class should not be called directly')

  file { '/etc/sudoers.d/classroom':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/classroom/sudoers.classroom',
  }
}


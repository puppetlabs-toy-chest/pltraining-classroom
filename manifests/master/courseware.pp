class classroom::master::courseware (
  $variant = 'ILT',
) {
  assert_private('This class should not be called directly')

  $source = $variant ? {
    'ILT'  => 'git@github.com:puppetlabs/courseware.git',
    'OILT' => 'git@github.com:puppetlabs/courseware-virtual.git',
  }

  include showoff

  # This depends on you configuring an sshkey in hiera
  $sshkey = hiera('sshkey')

  file { "/home/${showoff::user}/.ssh/id_rsa":
    ensure  => file,
    owner   => $showoff::user,
    group   => $showoff::group,
    mode    => '0600',
    content => $puppetlabs_training_sshkey,
    require => Class['showoff'],
  }

  sshkey { 'github key':
    name         => 'github.com',
    host_aliases => '192.30.252.129',
    type         => 'ssh-rsa',
    target       => "/home/${showoff::user}/.ssh/known_hosts",
    key          => $classroom::github_host_key,
  }

  vcsrepo { "${showoff::root}/courseware":
    ensure   => present,
    provider => git,
    user     => $showoff::user,
    source   => $source,
    require  => Sshkey['github key'],
  }
}
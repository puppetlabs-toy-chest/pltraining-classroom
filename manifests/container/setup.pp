# This Class sets up the docker environment and image(s)
#
class classroom::container::setup {
  include docker

  $container_volumes =  $::os['release']['major'] ? {
    '6' => [
      '/var/yum:/var/yum',
      '/etc/docker/ssl_dir/:/etc/puppetlabs/puppet/ssl',
    ],
    '7' => [
      '/var/yum:/var/yum',
      '/sys/fs/cgroup:/sys/fs/cgroup:ro',
      '/etc/docker/ssl_dir/:/etc/puppetlabs/puppet/ssl',
    ],
  }

  file { ['/etc/docker/agent/','/etc/docker/ssl_dir/']:
    ensure  => directory,
    require => Class['docker'],
  }

  $docker_files = [
    "Dockerfile",
    "base_local.repo",
    "epel_local.repo",
    "puppet.conf",
    "updates_local.repo",
  ]
  $docker_files.each |$docker_file|{
    file { "/etc/docker/agent/${docker_file}":
      ensure  => file,
      content => epp("classroom/dockeragent/${docker_file}.epp",{ 'os_major' => $::os['release']['major'] }),
    }
  }

  file { '/usr/local/bin/run_agents':
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/classroom/run_agents',
  }

  docker::image {'agent':
    docker_dir => '/etc/docker/agent/',
    require    => File['/etc/docker/agent/'],
  }
}

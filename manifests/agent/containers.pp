# This Class sets up the docker environment and containers
#
class classroom::agent::containers (
  $container_data
)
{
  include docker


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
      ensure   => file,
      content => epp("classroom/dockeragent/${docker_file}.epp",{ 'os_major' => $::os['release']['major'] }),
    }
  }

  file { '/usr/local/bin/run_agents':
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/classroom/run_agents.sh',
  }

  docker::image {'agent':
    docker_dir => '/etc/docker/agent/',
    require    => File['/etc/docker/agent/'],
  }

  if $::ipaddress_docker0 {
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
    $container_data.each |$container_name, $container_ports| {
      docker::run { $container_name:
        image            => 'agent',
        command          => '/sbin/init 3',
        use_name         => true,
        privileged       => true,
        volumes          => $container_volumes,
        extra_parameters => [
          "--add-host \"${::fqdn} puppet:${::ipaddress_docker0}\"",
          '--restart=always',
        ],
        require          => [
          Docker::Image['agent'],
          File['/etc/docker/ssl_dir/']
        ],
        hostname => $container_name,
        ports    => $container_ports,
      }
    }
  }

  # For dummy containers that stop immediately after running puppet:
  #docker::run {'dummy1.puppetlabs.vm':
  #  command  => 'puppet agent -t',
  #  hostname => 'dummy1.puppetlabs.vm',
  #}

  } else {
    notice('ipaddress_docker0 is not yet defined, rerun puppet to configure docker containers')
  }
}

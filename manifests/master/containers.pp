# This Class sets up the docker environment and containers
#
class classroom::master::containers (
  $container_data
) 
{
  include docker

  file { '/etc/docker/agent/':
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/classroom/dockeragent/',
    require => Class['docker'],
  }
  file { '/etc/docker/ssl_dir/':
    ensure => directory,
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
    Docker::Run {
      image            => 'agent',
      command          => '/sbin/init 3',
      use_name         => true,
      privileged       => true,
      volumes          => [
        '/var/yum:/var/yum',
        '/sys/fs/cgroup:/sys/fs/cgroup:ro',
        '/etc/docker/ssl_dir/:/etc/puppetlabs/puppet/ssl',
      ],
      extra_parameters => [
        "--add-host \"${::fqdn} puppet:${::ipaddress_docker0}\"",
        '--restart=always',
      ],
      require          => [
        Docker::Image['agent'],
        File['/etc/docker/ssl_dir/']
      ],
    }
    $container_data.each |$container_name, $container_ports| {
      docker::run { $container_name:
        hostname => $container_name,
        ports    => $container_ports,
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

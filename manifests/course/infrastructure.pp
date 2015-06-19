# This Class sets up the docker environment and containers for
# the Infrastructure course
#
class classroom::course::infrastructure {
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

  docker::image {'agent':
    docker_dir => '/etc/docker/agent/',
    require    => File['/etc/docker/agent/'],
  }

  Docker::Run {
    image            => 'agent',
    command          => '/sbin/init 3',
    use_name         => true,
    privileged       => true,
    volumes          => [
                          '/var/yum:/var/yum',
                          '/sys/fs/cgroup:/sys/fs/cgroup:ro',
                          '/etc/docker/ssl_dir/:/etc/puppetlabs/puppet/ssl'
                        ],
    extra_parameters => [
                          "--add-host \"${fqdn} master.puppetlabs.vm puppet:${ipaddress_docker0}\"",
                          "--restart=always"
                        ],
    require          => [
                          Docker::Image['agent'],
                          File['/etc/docker/ssl_dir/']
                        ],
  }
  docker::run { 'agent1.puppetlabs.vm':
    hostname         => 'agent1.puppetlabs.vm',
    ports            => ['10080:80'],
  }
  docker::run { 'agent2.puppetlabs.vm':
    hostname         => 'agent2.puppetlabs.vm',
    ports            => ['20080:80'],
  }
  docker::run { 'agent3.puppetlabs.vm':
    hostname         => 'agent3.puppetlabs.vm',
    ports            => ['30080:80'],
  }
  docker::run { 'agent4.puppetlabs.vm':
    hostname         => 'agent4.puppetlabs.vm',
    ports            => ['40080:80'],
  }
  docker::run { 'agent5.puppetlabs.vm':
    hostname         => 'agent5.puppetlabs.vm',
    ports            => ['50080:80'],
  }
  docker::run { 'agent6.puppetlabs.vm':
    hostname         => 'agent6.puppetlabs.vm',
    ports            => ['60080:80'],
  }

}

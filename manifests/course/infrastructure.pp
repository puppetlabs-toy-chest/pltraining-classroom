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

  docker::image {'agent':
    docker_dir => '/etc/docker/agent/',
    require    => File['/etc/docker/agent/'],
  }

  docker::run { 'agent1.puppetlabs.vm':
    image            => 'agent',
    command          => '/sbin/init 3',
    hostname         => 'agent1.puppetlabs.vm',
    ports            => ['10080:80'],
    use_name         => true,
    volumes          => ['/var/yum:/var/yum', '/sys/fs/cgroup:/sys/fs/cgroup:ro'],
    extra_parameters => "--add-host \"${fqdn} master.puppetlabs.vm puppet:${ipaddress_docker0}\"",
    require          => Docker::Image['agent'],
  }
  docker::run { 'agent2.puppetlabs.vm':
    image            => 'agent',
    command          => '/sbin/init 3',
    hostname         => 'agent2.puppetlabs.vm',
    ports            => ['20080:80'],
    use_name         => true,
    volumes          => ['/var/yum:/var/yum', '/sys/fs/cgroup:/sys/fs/cgroup:ro'],
    extra_parameters => "--add-host \"${fqdn} master.puppetlabs.vm puppet:${ipaddress_docker0}\"",
    require          => Docker::Image['agent'],
  }
  docker::run { 'agent3.puppetlabs.vm':
    image            => 'agent',
    command          => '/sbin/init 3',
    hostname         => 'agent3.puppetlabs.vm',
    ports            => ['30080:80'],
    use_name         => true,
    volumes          => ['/var/yum:/var/yum', '/sys/fs/cgroup:/sys/fs/cgroup:ro'],
    extra_parameters => "--add-host \"${fqdn} master.puppetlabs.vm puppet:${ipaddress_docker0}\"",
    require          => Docker::Image['agent'],
  }
  docker::run { 'agent4.puppetlabs.vm':
    image            => 'agent',
    command          => '/sbin/init 3',
    hostname         => 'agent4.puppetlabs.vm',
    ports            => ['40080:80'],
    use_name         => true,
    volumes          => ['/var/yum:/var/yum', '/sys/fs/cgroup:/sys/fs/cgroup:ro'],
    extra_parameters => "--add-host \"${fqdn} master.puppetlabs.vm puppet:${ipaddress_docker0}\"",
    require          => Docker::Image['agent'],
  }
  docker::run { 'agent5.puppetlabs.vm':
    image            => 'agent',
    command          => '/sbin/init 3',
    hostname         => 'agent5.puppetlabs.vm',
    ports            => ['50080:80'],
    use_name         => true,
    volumes          => ['/var/yum:/var/yum', '/sys/fs/cgroup:/sys/fs/cgroup:ro'],
    extra_parameters => "--add-host \"${fqdn} master.puppetlabs.vm puppet:${ipaddress_docker0}\"",
    require          => Docker::Image['agent'],
  }
  docker::run { 'agent6.puppetlabs.vm':
    image            => 'agent',
    command          => '/sbin/init 3',
    hostname         => 'agent6.puppetlabs.vm',
    ports            => ['60080:80'],
    use_name         => true,
    volumes          => ['/var/yum:/var/yum', '/sys/fs/cgroup:/sys/fs/cgroup:ro'],
    extra_parameters => "--add-host \"${fqdn} master.puppetlabs.vm puppet:${ipaddress_docker0}\"",
    require          => Docker::Image['agent'],
  }

}

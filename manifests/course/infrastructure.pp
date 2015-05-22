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

  docker::run { 'agent1':
    image            => 'agent',
    command          => '/sbin/init 3',
    hostname         => 'agent1',
    use_name         => true,
    volumes          => ['/va/yum:/var/yum'],
    extra_parameters => "--add-host \"${fqdn} master.puppetlabs.vm puppet:${ipaddress_docker0}\"",
    require          => Docker::Image['agent'],
  }

}

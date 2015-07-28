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
      "--add-host \"${::fqdn} master.puppetlabs.vm puppetfactory puppet:${::ipaddress_docker0}\"",
      '--restart=always',
    ],
    require          => [
      Docker::Image['agent'],
      File['/etc/docker/ssl_dir/']
    ],
  }

  docker::run { 'test.puppetlabs.vm':
    hostname => 'test.puppetlabs.vm',
    ports    => ['10080:80'],
  }
  docker::run { 'web1.puppetlabs.vm':
    hostname => 'web1.puppetlabs.vm',
    ports    => ['20080:80'],
  }
  docker::run { 'db2dev.puppetlabs.vm':
    hostname => 'db2dev.puppetlabs.vm',
    ports    => ['30080:80'],
  }
  docker::run { 'web2dev.puppetlabs.vm':
    hostname => 'web2dev.puppetlabs.vm',
    ports    => ['40080:80'],
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

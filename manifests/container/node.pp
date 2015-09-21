# Create and run a Docker containerized Puppet Agent
define classroom::container::node (
  $ports = undef,
) {
  require classroom::container::setup

  if $::ipaddress_docker0 {
    docker::run { $title:
      hostname         => $title,
      image            => 'agent',
      command          => '/sbin/init 3',
      use_name         => true,
      privileged       => true,
      ports            => $ports,
      volumes          => $classroom::container::setup::container_volumes,
      extra_parameters => [
        "--add-host \"${::fqdn} puppet:${::ipaddress_docker0}\"",
        '--restart=always',
      ],
    }

  } else {
    notify { 'Docker has not yet been configured on this node.': }
  }
}

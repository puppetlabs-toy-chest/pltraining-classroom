# This Class sets up the docker environment and containers for
# the Infrastructure course
#
class classroom::course::infrastructure {
    $containers = {
     'test.puppetlabs.vm'  => ['10080:80'],
     'web1.puppetlabs.vm'  => ['20080:80'],
     'db2dev.puppetlabs.vm' => ['30080:80'],
     'web2dev.puppetlabs.vm' => ['40080:80'],
    }

    $containers.each |$container_name,$ports| {
      dockeragent::node { $container_name:
        ports => $ports,
      }
    }
}

class classroom::containers {
  include dockeragent

  dockeragent::node { "agent1.${::fqdn}":
    ports => ['10080:80'],
  }
  dockeragent::node { "agent2.${::fqdn}":
    ports => ['20080:80'],
  }
}

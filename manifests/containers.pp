class classroom::containers {
  include classroom::container::setup

  classroom::container::node { "agent1.${::fqdn}":
    ports => ['10080:80'],
  }
  classroom::container::node { "agent2.${::fqdn}":
    ports => ['20080:80'],
  }
}

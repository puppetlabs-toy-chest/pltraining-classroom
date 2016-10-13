class classroom::master::gogs {

  include docker
  docker::run {'ciab-gogs':
    image   => 'joshsamuelson/gogs',
    ports   => ['10022:22','3000:3000'],
    volumes => ['/var/gogs:/data'],
    env     => [
      "DOMAIN=${::fqdn}",
    ],
  }
}


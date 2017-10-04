class classroom::agent::sshauth {

  # The public half of this key is on the Downloads page of the Courseware presentation
  ssh_authorized_key { 'training@puppet.com':
    ensure => present,
    user   => 'training',
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDT4hxLhcccJhKRHp5uSEpmE3EgXaOlL72qI7T8cJOh/hov/MsCd8IVGc1fE1romqCjS6vITn9L/tPeJOwmGSih0iUWEQd6CY/OZttdnlelwaGke12hPiuqYqEqGcExNrGoynTQWMz99T6cdyd9HptCGdYGK1EwCi3hmv9QBZGChUbnQKqi3Zc1Uubpzp6WyTXaDoxLxlxX7QXt8K7cRaAviDZ/I07svoO9RwZPqGyeeyh4k1pAYTik8jY58rMmDCNcp6jM4AWAF786k77GI/DBzACJ7kt1Qe8fGLlm7UyV/nSZhxiKs3TcfqBypPf+tQzvfvSfRdVvoMQQOw38ogqT',
  }

}

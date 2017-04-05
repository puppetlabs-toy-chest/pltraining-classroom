class classroom::agent::packages {
  $packages = [
    'openssl',         # used for generating password hashes for user resources
  ]

  package { $packages:
    ensure => present,
  }
}

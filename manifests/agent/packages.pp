class classroom::agent::packages {

  $packages = $osfamily ? {
    'windows' => [],
    default   => [
      'openssl',         # used for generating password hashes for user resources
    ],
  }
  
  package { $packages:
    ensure => present,
  }
}

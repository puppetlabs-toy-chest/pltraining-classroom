# Create a classroom user on the master
define classroom::user (
  $password,
  $key         = undef,
  $consolepw   = undef,
  $manage_repo = true,
) {
  File {
    owner => $name,
    group => 'pe-puppet',
    mode  => '0644',
  }

  # A valid hostname is not necessarily a valid Puppet environment name!
  validate_re($name, '^(?=.*[a-z])\A[a-z0-9][a-z0-9._]+\z', "The classroom environment supports lowercase alphanumeric hostnames only. ${name} is not a valid name. Please ask your instructor for assistance.")

  user { $name:
    ensure   => present,
    gid      => 'pe-puppet',
    password => $password,
    home     => "/home/${name}",
  }

  file { "/home/${name}":
    ensure => directory,
  }

  file { "/home/${name}/.ssh":
    ensure => directory,
    mode   => '0600',
  }

  if $key {
    ssh_authorized_key { $name:
      key     => $key,
      type    => 'ssh-rsa',
      user    => $name,
      require => File["/home/${name}/.ssh"],
    }
  }

  if $consolepw {
    classroom::console::user { $name:
      password => $consolepw,
    }
  }

  if $manage_repo {
    classroom::master::repository { $name:
      ensure => present,
    }
  }

}

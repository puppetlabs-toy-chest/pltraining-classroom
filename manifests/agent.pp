# This class configures the agent with
#  * root sshkey
#  * git source repository
#  * git pre-commit hook
#  * hiera configuration
#  * time synchronization with the classroom master
class classroom::agent {
  assert_private('This class should not be called directly')

  # A valid clientcert is not necessarily a valid Puppet environment name!
  validate_re($classroom::machine_name, '^(?=.*[a-z])\A[a-z0-9][a-z0-9._]+\z', "The classroom environment supports lowercase alphanumeric names only. ${name} is not a valid name. Please ask your instructor for assistance.")

  # windows goodies
  if $::osfamily  == 'windows' {
    include classroom::windows
  }
  else {
    # /etc/puppet/ssl is confusing to have around. Sloppy. Kill.
    file {'/etc/puppet':
      ensure  => absent,
      recurse => true,
      force   => true,
    }
  }

  # make sure our git environment is set up and usable
  include classroom::agent::git

  # Make sure that Hiera is configured for all nodes so that we
  # can work through the hiera sections without teaching them
  # how to configure it.
  include classroom::agent::hiera

  # Ensure that the time is always synced with the classroom master
  include classroom::agent::time

  # export a classroom::user with our ssh key.
  #
  # !!!! THIS MAY EXPORT AN EMPTY KEY ON THE FIRST RUN !!!!
  #
  # On the second run, the ssh key will exist and so this fact will be set.
  @@classroom::user { $::classroom::params::machine_name:
    key        => $::root_ssh_key,
    password   => $classroom::password,
    consolepw  => $classroom::consolepw,
    managerepo => $classroom::managerepos,
  }

  # if we are managing git repositories, then build out all this
  if $classroom::managerepos {

    classroom::agent::workdir { $classroom::workdir:
      ensure   => present,
      username => $classroom::params::machine_name,
      require  => Class['classroom::agent::git'],
    }

    # If we have teams defined for this node, build a working directory for each.
    include classroom::agent::teams
  }
}

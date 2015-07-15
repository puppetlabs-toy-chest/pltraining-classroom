# Make sure that Hiera is configured for agent nodes so that we
# can work through the hiera sections without teaching them
# how to configure it.
class classroom::agent::hiera {
  assert_private('This class should not be called directly')

  # Set defaults depending on os
  case $::osfamily {
    'windows' : {
      File {
        owner => 'Administrator',
        group => 'Users',
      }
    }
    default   : {
      File {
        owner => 'root',
        group => 'root',
        mode  => '0644',
      }
    }
  }

  $hieradata = "${$classroom::codedir}/hieradata"

  if $classroom::managerepos {
    file { $hieradata:
      ensure => link,
      target => "${classroom::workdir}/hieradata",
    }

    file { "${classroom::codedir}/hiera.yaml":
      ensure => link,
      target => "${classroom::workdir}/hiera.yaml",
      force  => true,
    }

    file { "${classroom::workdir}/hiera.yaml":
      ensure => file,
      source => 'puppet:///modules/classroom/hiera/hiera.agent.yaml',
      replace => false,
    }

  }
  else {
    file { $hieradata:
      ensure => directory,
    }

    # Because PE writes a default, we cannot use replace => false
    file { "${classroom::codedir}/hiera.yaml":
      ensure => file,
      source => 'puppet:///modules/classroom/hiera/hiera.agent.yaml',
    }
  }

  file { "${hieradata}/defaults.yaml":
    ensure  => file,
    source  => 'puppet:///modules/classroom/hiera/data/defaults.yaml',
    replace => false,
  }
}

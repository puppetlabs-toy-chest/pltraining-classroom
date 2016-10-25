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

  $hieradata = "${classroom::codedir}/hieradata"

  if $classroom::manage_repos {
    file { $hieradata:
      ensure => link,
      # the hieradata dir is empty so forcing to
      # replace directory with symlink on Win 2012
      force => true,
      target => "${classroom::workdir}/hieradata",
    }

    file { "${classroom::confdir}/hiera.yaml":
      ensure => link,
      target => "${classroom::workdir}/hiera.yaml",
      force  => true,
    }

    file { "${classroom::workdir}/hiera.yaml":
      ensure  => file,
      content => epp('classroom/hiera/hiera.agent.yaml.epp', { 'hieradata' => $hieradata }),
      replace => false,
    }

  }
  else {
    file { $hieradata:
      ensure => directory,
    }

    # Because PE writes a default, we have to do tricks to see if we've already managed this.
    unless defined('$puppetlabs_class') {
      file { "${classroom::confdir}/hiera.yaml":
        ensure  => file,
        content => epp('classroom/hiera/hiera.agent.yaml.epp', { 'hieradata' => $hieradata }),
      }
    }
  }

  file { "${hieradata}/common.yaml":
    ensure  => file,
    source  => 'puppet:///modules/classroom/hiera/data/common.yaml',
    replace => false,
  }
}

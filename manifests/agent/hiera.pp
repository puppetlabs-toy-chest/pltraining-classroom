# Make sure that Hiera is configured for agent nodes so that we
# can work through the hiera sections without teaching them
# how to configure it.
class classroom::agent::hiera (
  $codedir = $classroom::params::codedir,
  $confdir = $classroom::params::confdir,
  $workdir = $classroom::params::workdir,
) inherits classroom::params {
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

  $hieradata = "${codedir}/hieradata"

  if $classroom::manage_repos {
    file { $hieradata:
      ensure => link,
      # the hieradata dir is empty so forcing to
      # replace directory with symlink on Win 2012
      force  => true,
      target => "${workdir}/hieradata",
    }

    file { "${confdir}/hiera.yaml":
      ensure => link,
      target => "${workdir}/hiera.yaml",
      force  => true,
    }

    file { "${workdir}/hiera.yaml":
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
      file { "${confdir}/hiera.yaml":
        ensure  => file,
        content => epp('classroom/hiera/hiera.agent.yaml.epp', { 'hieradata' => $hieradata }),
      }
    }
  }

  unless $::osfamily == 'windows' {
    file { '/usr/local/bin/hiera_explain.rb':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0777',
      source => 'puppet:///modules/classroom/hiera_explain.rb',
    }
  }

  file { "${hieradata}/common.yaml":
    ensure  => file,
    source  => 'puppet:///modules/classroom/hiera/data/common.yaml',
    replace => false,
  }
}

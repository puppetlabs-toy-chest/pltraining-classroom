# Make sure that Hiera is configured for the master so that we
# can demo and so we can use hiera for configuration.
class classroom::master::hiera {
  assert_private('This class should not be called directly')

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  $hieradata = "${classroom::params::confdir}/hieradata"

  # Because PE writes a default, we have to do tricks to see if we've already managed this.
  # We don't want to stomp on instructors doing demonstrations.
  unless defined('$puppetlabs_class') {
    file { "${classroom::params::confdir}/hiera.yaml":
      ensure  => file,
      content => epp('classroom/hiera/hiera.master.yaml.epp', { 'hieradata' => $hieradata })
    }
  }

  # we need a global hieradata directory that's outside of the control repositories
  # so that we can define sources for code manager (classroom::master::codemanager)
  file { $hieradata:
    ensure => directory,
  }

  # place the environments link in place only on the master. This allows
  # us to have a global hieradata dir as well as a per-env hieradata dir
  # enabling the use of Hiera within student environments.
  file { "${hieradata}/environments":
    ensure => link,
    target => "${classroom::params::codedir}/environments",
  }

  file { "${hieradata}/common.yaml":
    ensure  => file,
    source  => 'puppet:///modules/classroom/hiera/data/common.yaml',
    replace => false,
  }

  # classroom parameters
  file { "${hieradata}/classroom.yaml":
    ensure  => file,
    source  => 'puppet:///modules/classroom/hiera/data/classroom.yaml',
    replace => false,
  }

  # overrides for the master, but allow the instructor to edit
  file { "${hieradata}/master.puppetlabs.vm.yaml":
    ensure  => file,
    source  => 'puppet:///modules/classroom/hiera/data/master.puppetlabs.vm.yaml',
    replace => false,
  }

}

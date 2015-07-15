# Make sure that Hiera is configured for the master so that we
# can demo and so we can use hiera for configuration.
class classroom::master::hiera {
  assert_private('This class should not be called directly')

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  $hieradata = "${classroom::codedir}/hieradata"

  file { "${classroom::codedir}/hiera.yaml":
    ensure => file,
    source => 'puppet:///modules/classroom/hiera/hiera.master.yaml',
  }

  # we need a global hieradata directory
  file { $hieradata:
    ensure => directory,
  }

  # place the environments link in place only on the master. This allows
  # us to have a global hieradata dir as well as a per-env hieradata dir
  # enabling the use of Hiera within student environments.
  file { "${hieradata}/environments":
    ensure => link,
    target => "${classroom::codedir}/environments",
  }

  file { "${hieradata}/defaults.yaml":
    ensure  => file,
    source  => 'puppet:///modules/classroom/hiera/data/defaults.yaml',
    replace => false,
  }

  # classroom parameters
  file { "${hieradata}/classroom.yaml":
    ensure => file,
    source => 'puppet:///modules/classroom/hiera/data/classroom.yaml',
  }

  # overrides for the master, but allow the instructor to edit
  file { "${hieradata}/master.puppetlabs.vm.yaml":
    ensure  => file,
    source  => 'puppet:///modules/classroom/hiera/data/master.puppetlabs.vm.yaml',
    replace => false,
  }

}

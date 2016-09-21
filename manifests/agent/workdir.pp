# This creates a working directory on the agent and adds a
# remote pointing back to the master. It can populate the
# directory with some starter code for the student to check in.
#
# $name: path of workdir
# $username: the username for git operations. Defaults to $name
# $populate: add starter code
define classroom::agent::workdir (
  $ensure     = 'present',
  $username   = $name,
  $populate   = true,
) {

  # Set defaults depending on os
  case $::osfamily {
    'windows' : {
      $environment = undef
      $path = 'C:\Program Files\Git\bin'
      File {
        ensure => file,
        owner  => 'Administrator',
        group  => 'Users',
      }
    }
    default   : {
      $environment = 'HOME=/root'
      $path = '/usr/bin:/bin:/user/sbin:/usr/sbin'
      File {
        ensure => file,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }
    }
  }
  Exec {
    environment => $environment,
    path        => $path,
  }

  $workdir = $name

  if $ensure == 'present' {
    file { $workdir:
      ensure => directory,
    }

    file { "${classroom::codedir}/modules":
      ensure => link,
      target => "${workdir}/modules",
      force  => true,
    }

    # Install workdir symlink on the user desktop and configure git on
    # Windows to handle various file types as binary.
    if $::osfamily == 'Windows' {
      $linkname = basename($workdir)
      file { "C:/Users/Administrator/Desktop/${linkname}":
        ensure => link,
        target => $workdir,
      }

      file { "${workdir}/.gitattributes":
        ensure  => file,
        source  => 'puppet:///modules/classroom/dot_gitattributes_windows',
        require => Exec["initialize ${name} repo"],
      }
    }

    if $populate {
      # create the modules, manifests, site.pp and environment.conf
      # environment.conf required to prevent caching
      file { "${workdir}/manifests":
        ensure => directory,
      }

      file { "${workdir}/manifests/site.pp":
        source  => 'puppet:///modules/classroom/site.pp',
        replace => false,
      }

      file { "${workdir}/manifests/classroom.pp":
        source  => 'puppet:///modules/classroom/classroom.pp',
        replace => false,
      }

      file { "${workdir}/modules":
        ensure => directory,
      }

      file { "${workdir}/modules/profile":
        ensure => directory,
      }

      file { "${workdir}/modules/profile/manifests":
        ensure => directory,
      }

      file { "${workdir}/modules/profile/manifests/base.pp":
        source  => 'puppet:///modules/classroom/modules/profile/manifests/base.pp',
        replace => false,
      }

      file { "${workdir}/modules/role":
        ensure => directory,
      }

      file { "${workdir}/modules/role/manifests":
        ensure => directory,
      }

      file { "${workdir}/modules/role/manifests/classroom.pp":
        source  => 'puppet:///modules/classroom/modules/role/manifests/classroom.pp',
        replace => false,
      }

      file { "${workdir}/hieradata":
        ensure => directory,
      }

    }

    # Can't use vcsrepo because we cannot clone.
    exec { "initialize ${name} repo":
      command => "git init ${workdir}",
      creates => "${workdir}/.git",
      require => File[$workdir],
    }

    exec { "add git remote for ${name}":
      unless  => "git --git-dir ${workdir}/.git config remote.origin.url",
      command => "git --git-dir ${workdir}/.git remote add origin ${username}@master.puppetlabs.vm:/var/repositories/${username}.git",
      require => Exec["initialize ${name} repo"],
    }

    if $::osfamily != 'windows' {
      file { "${workdir}/.git/hooks/pre-commit":
        source  => 'puppet:///modules/classroom/pre-commit',
        mode    => '0755',
        require => Exec["initialize ${name} repo"],
      }
    }

    file { "${workdir}/.gitignore":
      source  => 'puppet:///modules/classroom/dot_gitignore',
      require => Exec["initialize ${name} repo"],
    }

  }
  else {
    file { $workdir:
      ensure => absent,
      force  => true,
    }
  }

}

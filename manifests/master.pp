# Set up the master with user accounts, environments, etc
class classroom::master {
  assert_private('This class should not be called directly')

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  # Workaround for pip
  file {'/usr/bin/pip-python':
    ensure => link,
    target => '/usr/bin/pip',
  }

  if $classroom::offline {
    # Install the Gitea hosted git repository service
    include classroom::master::gitea

    # Reconfigure the gemrc files for offline use
    $gemrc_files = [ '/root/.gemrc', '/opt/puppetlabs/puppet/etc/gemrc' ]

    $gemrc_files.each |$gemrc_file| {
      file { $gemrc_file:
        ensure => file,
      }

      # Remove this line so "gem install" doesn't try to access
      # the rubygems.org site, even though the local gem cache
      # is configured. Seems to work better if this line is removed
      # altogether.
      file_line { "Remove rubygems.org from ${gemrc_file} when offline":
        ensure            => absent,
        path              => $gemrc_file,
        match             => '\-\ https:\/\/rubygems\.org',
        match_for_absence => true,
      }
    }
  }

  # Add the installer files for student agents
  # These files are cached by the build, so this will work offline
  include pe_repo::platform::el_6_i386
  include pe_repo::platform::windows_x86_64

  # Ensure the environment cache is disabled and restart if needed
  ini_setting {'environment timeout':
    ensure  => present,
    path    => "${classroom::confdir}/puppet.conf",
    section => 'main',
    setting => 'environment_timeout',
    value   => '0',
    notify  => Service['pe-puppetserver'],
  }

  # This is stupid, but it allows the rspec-puppet tests to pass
#  Ini_setting['environment timeout'] -> Service<| title == 'pe-puppetserver' |>

  # Anything that needs to be top scope
  file { "${classroom::codedir}/environments/production/manifests/classroom.pp":
    ensure => file,
    source => 'puppet:///modules/classroom/classroom.pp',
  }

  # if configured to do so, configure repos & environments on the master. This
  # overrides the resource in the puppet_enterprise module and allows us to have
  # different users updating their own repositories.
  if $classroom::manage_repos {
    $environmentspath = "${classroom::codedir}/environments"

    # 2015.2.x manages the environmentpath but doesn't allow users to write
    if versioncmp($::pe_server_version,'2015.3.0') < 0 {
      File <| title == $environmentspath |> {
        mode => '1777',
      }
    }
    # 2015.3.x doesn't manage the environmentpath
    else {
      file { $environmentspath:
        ensure => directory,
        mode   => '1777',
      }
    }

    include classroom::master::repositories
  }

  # Install showoff on the classroom master
  include classroom::master::showoff

  # Ensure that time is set appropriately
  include classroom::master::time

  # configure Hiera environments for the master
  include classroom::master::hiera

  # Setup Windows Powershell Scripts
  include classroom::master::windows

  # Now create all of the users who've checked in
  Classroom::User <<||>>

  # Add files required for labs (mostly for offline mode)
  include classroom::master::lab_files

  # Configure performance logging
  include classroom::master::perf_logging

}

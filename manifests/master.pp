# Set up the master with user accounts, environments, etc
class classroom::master {
  assert_private('This class should not be called directly')

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  # Add the installer files for 32bit agents
  # These files are cached by the build, so this will work offline
  include pe_repo::platform::el_6_i386

  # we know that you all love logging back into the Console every time you do a
  # demo, but we're sadists, so we're going to take that pleasure away from you.
  # Newer PE versions are configured via Hiera key
  if versioncmp($::pe_version, '3.7.0') < 0 {
    file { '/etc/puppetlabs/console-services/conf.d/rbac-session.conf':
      ensure => file,
      source => 'puppet:///modules/classroom/rbac-session.conf',
      notify => Service['pe-console-services'],
    }
  }

  # https://docs.puppetlabs.com/puppet/latest/reference/environments_configuring.html#environmenttimeout
  # Suggests that this setting can be pushed up to puppet.conf globally.
  # Initial testing appears to confirm that. If this proves problematic, then
  # uncomment this resource and the relevant resource in classroom::agent::workdir
  # file { "/etc/puppetlabs/puppet/environments/production/environment.conf":
  #   ensure  => file,
  #   content => "environment_timeout = 0\n",
  #   replace => false,
  # }

  # Ensure the environment cache is disabled and restart if needed
  ini_setting {'environment timeout':
    ensure  => present,
    path    => "${classroom::confdir}/puppet.conf",
    section => 'main',
    setting => 'environment_timeout',
    value   => '0',
    notify  => Service['pe-puppetserver'],
  }

  # Anything that needs to be top scope
  file { "${classroom::codedir}/environments/production/manifests/classroom.pp":
    ensure => file,
    source => 'puppet:///modules/classroom/classroom.pp',
  }

  # if configured to do so, configure repos & environments on the master. This
  # overrides the resource in the puppet_enterprise module and allows us to have
  # different users updating their own repositories.
  if $classroom::managerepos {
    File <| title == "${classroom::codedir}/environments" |> {
      mode => '1777',
    }

    include classroom::master::repositories
  }

  # Ensure that time is set appropriately
  include classroom::master::time

  # unselect all nodes in Live Management by default
  #include classroom::console::patch

  # Now create all of the users who've checked in
  Classroom::User <<||>>

  # The new PE stack takes a very long time to startup, which can cause
  # disconcerting errors. This simply schedules that to the end of the run
  # and waits for the service to resume servicing requests before allowing
  # the run to complete
  include classroom::master::wait_for_startup

  # Add autoteam yaml
  include classroom::master::autoteam
}

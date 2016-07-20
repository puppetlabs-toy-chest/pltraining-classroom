# This is a wrapper class to include all the bits needed for Puppetizing infrastructure
class classroom::course::puppetize (
  $offline      = $classroom::params::offline,
  $manageyum    = $classroom::params::manageyum,
  $time_servers = $classroom::params::time_servers,
  $session_id   = $classroom::params::session_id,
) inherits classroom::params {
  # TODO: This class needs some refactoring, too much cutty-pastey

  if $::fqdn == 'master.puppetlabs.vm' {
    # Classroom Master
    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    include classroom::master::dependencies::dashboard
    include classroom::master::dependencies::rubygems
    include classroom::master::codemanager
    include classroom::master::showoff

    class { 'puppetfactory':
      prefix               => false,
      map_environments     => true,
      puppetcode           => '/var/opt/puppetcode',
      map_modulepath       => false,
      readonly_environment => true,
      dashboard            => "${showoff::root}/courseware/_files/tests",
      session_id           => $session_id,
      gitlab_enabled       => false,
    }

    file { '/usr/local/bin/validate_classification.rb':
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/classroom/validation/puppetize.rb',
    }

    # Because PE writes a default, we have to do tricks to see if we've already managed this.
    # We don't want to stomp on instructors doing demonstrations.
    unless defined('$puppetlabs_class') {
      file { '/etc/puppetlabs/code-staging/hiera.yaml':
        ensure => file,
        source => 'puppet:///modules/classroom/hiera/hiera.code-manager.yaml',
      }
    }

  } elsif $::osfamily == 'windows' {

    # TODO: copied from classroom::windows, in the sake of rapid development
    user { 'Administrator':
      ensure => present,
      groups => ['Administrators'],
    }

    # Windows Agents
    include chocolatey
    include classroom::windows::disable_esc
    include classroom::windows::geotrust
    windows_env { 'PATH=C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin': }
  }

  # All nodes
  include classroom::agent::git
  class { 'classroom::facts':
    coursename => 'puppetizing',
  }

}

# This is a wrapper class to include all the bits needed for Puppetizing infrastructure
class classroom::course::puppetize (
  $instructor_github_account,
  $offline      = $classroom::params::offline,
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
    include classroom::master::showoff
    include classroom::master::hiera


    class { 'puppetfactory':
      plugins          => [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "Dashboard", "CodeManager", "ShellUser", "Gitviz" ],
      controlrepo      => 'classroom-control-pi.git',
      repomodel        => 'single',
      usersuffix       => $classroom::params::usersuffix,
      session          => $session_id,
      privileged       => true,
    }

    file { '/usr/local/bin/validate_classification.rb':
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/classroom/validation/puppetize.rb',
    }

    class { 'classroom::master::codemanager':
      control_repo  => 'classroom-control-pi.git',
      control_owner => $instructor_github_account,
      offline       => $offline,
    }

  } elsif $::osfamily == 'windows' {

    # TODO: copied from classroom::windows, in the sake of rapid development
    user { 'Administrator':
      ensure => present,
      groups => ['Administrators'],
    }

    chocolateyfeature { 'allowEmptyChecksums':
      ensure => enabled,
    }
    Chocolateyfeature['allowEmptyChecksums'] -> Package<| provider == 'chocolatey' |>

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

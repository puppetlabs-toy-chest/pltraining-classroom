class classroom::course::virtual::practitioner (
  $control_owner = undef,
  $offline       = $classroom::params::offline,
  $session_id    = $classroom::params::session_id,
) inherits classroom::params {
  include classroom::virtual

  include classroom::master::reporting_tools

  if $role == 'master' {
    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    include classroom::master::hiera
    include classroom::master::dependencies::dashboard

    class { 'puppetfactory':
      plugins          => [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "Dashboard", "CodeManager", "ShellUser" ],
      controlrepo      => 'classroom-control-vp.git',
      repomodel        => 'single',
      usersuffix       => $classroom::params::usersuffix,
      dashboard_path   => "${showoff::root}/courseware/_files/tests",
      session          => $session_id,
      privileged       => false,
    }

    class { 'classroom::facts':
      coursename => 'practitioner',
    }

    class { 'classroom::master::codemanager':
      control_owner => $control_owner,
      control_repo  => 'classroom-control-vp.git',
      offline       => $offline,
    }

  }
  elsif $role == 'agent' {
    puppet_enterprise::mcollective::client { 'peadmin':
      activemq_brokers => ['master.puppetlabs.vm'],
      keypair_name     => 'pe-internal-peadmin-mcollective-client',
      create_user      => true,
      logfile          => '/var/lib/peadmin/.mcollective.d/client.log',
      stomp_password   => chomp(file('/etc/puppetlabs/mcollective/credentials','/dev/null')),
      stomp_port       => 61613,
      stomp_user       => 'mcollective',
    }
  }

}

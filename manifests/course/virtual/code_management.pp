class classroom::course::virtual::code_management (
  $session_id = $classroom::params::session_id,
  $role       = $classroom::params::role,
) inherits classroom::params {
  include classroom::virtual

  if $role == 'master' {
    class { 'puppetfactory':
      plugins          => [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "R10k", "ShellUser", "Gitviz" ],
      controlrepo      => 'classroom-control-mpc.git',
      usersuffix       => $classroom::params::usersuffix,
      session          => $session_id,
      privileged       => false,
    }

    class { 'r10k':
      remote => 'https://github.com/puppetlabs-education/classroom-control-mpc.git',
    }

  } else {
    include r10k
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

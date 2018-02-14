# typing the parameters doesn't actually gain us anything, since the
# Console doesn't provide any hinting. Subclasses validate types.
class classroom::course::virtual::practitioner (
  $event_id           = undef,
  $event_pw           = undef,
  $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
  $offline            = $classroom::params::offline,
  $version            = undef,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
    control_repo       => 'classroom-control-vp.git',
    event_id           => $event_id,
    event_pw           => $event_pw,
  }

  if $role == 'master' {
    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    include classroom::master::reporting_tools

    class { 'classroom::facts':
      coursename => 'practitioner',
    }

    class { 'classroom::master::showoff':
      course             => 'Practitioner',
      event_id           => $event_id,
      event_pw           => $event_pw,
      variant            => 'virtual',
      version            => $version,
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

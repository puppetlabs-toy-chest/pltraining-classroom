# This is a wrapper class to include all the bits needed for Practitioner
#
class classroom::course::practitioner (
  $offline            = $classroom::params::offline,
  $manage_yum         = $classroom::params::manage_yum,
  $time_servers       = $classroom::params::time_servers,
  $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
) inherits classroom::params {
  # just wrap the classroom class
  class { 'classroom':
    offline            => $offline,
    role               => $role,
    manage_yum         => $manage_yum,
    time_servers       => $time_servers,
    jvm_tuning_profile => $jvm_tuning_profile,
  }

  if $role == 'master' {
    # master gets reporting scripts
    include classroom::master::reporting_tools
    include classroom::master::sudoers
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

  class { 'classroom::facts':
    coursename => 'practitioner',
  }
}

class classroom::master::tuning (
  $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
) inherits classroom::params {
  assert_private('This class should not be called directly')

  require classroom::master::hiera

  if $jvm_tuning_profile != false {
    case $jvm_tuning_profile {
      'reduced': {
        $amq_heap_mb                = '256'
        $master_Xms                 = '512m'
        $master_Xmx                 = '1024m'
        $puppetdb_Xms               = '128m'
        $puppetdb_Xmx               = '384m'
        $console_Xms                = '128m'
        $console_Xmx                = '384m'
        $orch_Xms                   = '128m'
        $orch_Xmx                   = '256m'
        $jruby_max_active_instances = 1
        $delayed_job_workers        = 1
        $enable_app_mgmt            = 'false'
        $enable_orch_service        = 'false'
        $console_sync_period        = 0
      }
      default : {
        fail("Unknown tuning level '${jvm_tuning_profile}', choose one of: 'reduced' or false")
      }
    }
  }

  # The tuning file will be installed no matter what because
  # there are 1+ Hiera keys that remain whatever the tuning
  # profile is set to.
  file { "${classroom::params::confdir}/hieradata/tuning.yaml":
    ensure        => file,
    owner         => 'root',
    group         => 'root',
    mode          => '0644',
    content       => template('classroom/tuning.yaml.erb'),
    notify => Class['puppet_enterprise::profile::master',
                    'puppet_enterprise::profile::console',
                    'puppet_enterprise::profile::orchestrator',
                    'puppet_enterprise::profile::amq::broker'],
  }
}

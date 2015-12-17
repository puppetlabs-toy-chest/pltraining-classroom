# this file has no effect at the moment.
# https://github.com/rodjek/rspec-puppet/issues/322
#
# Set up artifacts required for the classroom module to apply cleanly
#
if $::hostname in ['master', 'puppetfactory'] {
  class { 'puppet_enterprise':
    mcollective_middleware_hosts => ["master.puppetlabs.vm"],
    use_application_services     => false,
    database_host                => "master.puppetlabs.vm",
    puppetdb_host                => "master.puppetlabs.vm",
    database_port                => "5432",
    database_ssl                 => true,
    puppet_master_host           => "master.puppetlabs.vm",
    certificate_authority_host   => "master.puppetlabs.vm",
    console_port                 => "443",
    puppetdb_database_name       => "pe-puppetdb",
    puppetdb_database_user       => "pe-puppetdb",
    pcp_broker_host              => "master.puppetlabs.vm",
    puppetdb_port                => "8081",
    console_host                 => "master.puppetlabs.vm",
    manage_symlinks              => true,
  }
  include puppet_enterprise::profile::master
}

class classroom::params {
  # Configure NTP (and other services) to run in standalone mode
  $offline   = false

  # Automatically configure environment, etc for students.
  $autosetup = false

  # automatically assign teams for the capstone
  $autoteam  = false

  if $::osfamily == 'windows' {
    # Path to the student's working directory
    $workdir = 'C:/puppetcode'
    $confdir = 'C:/ProgramData/PuppetLabs/puppet/etc'

    $codedir = $::aio_agent_version ? {
      undef   => 'C:/ProgramData/PuppetLabs/code',
      default => 'C:/ProgramData/PuppetLabs/puppet/etc/modules',
    }
  }
  else {
    $workdir = '/root/puppetcode'
    $confdir = '/etc/puppetlabs/puppet'
    $codedir = '/etc/puppetlabs/code'
  }

  # default user password
  $password  = '$1$Tge1IxzI$kyx2gPUvWmXwrCQrac8/m0' # puppetlabs
  $consolepw = 'puppetlabs'

  # Should we manage upstream yum repositories in the classroom?
  $manageyum = $::osfamily ? {
    'RedHat' => true,
    default  => false,
  }

  # Upstream yum repositories
  $repositories = [ 'base', 'extras', 'updates' ]

  # manage git repositories for the student and the master
  $managerepos = true

  # time servers to use if we've got network
  $time_servers = ['0.pool.ntp.org iburst', '1.pool.ntp.org iburst', '2.pool.ntp.org iburst', '3.pool.ntp.org']

  # where the agent installer tarball for secondary masters should go.
  $publicdir = $::aio_agent_version ? {
    undef   => '/opt/puppet/packages/public/classroom',
    default => '/opt/puppetlabs/server/data/packages/public/classroom',
  }

  # The directory where the VM caches stuff locally
  $cachedir = '/usr/src/installer'

  # Default timeout for operations requiring downloads or the like
  $timeout = 600

  # list of module repositorites that should be precreated for the virtual courses
  $precreated_repositories = [ 'critical_policy', 'registry', 'profiles' ]

  # Windows active directory setup parameters
  $ad_domainname           = 'CLASSROOM.local'
  $ad_netbiosdomainname    = 'CLASSROOM'
  $ad_dsrmpassword         = 'Puppetlabs1'

  # Tuning parameters for classroom master performance
  $jruby_purge        = false    # See https://tickets.puppetlabs.com/browse/PE-9704
  $jvm_tuning_profile = false    # Set to 'lvm', 'minimal', 'moderate', 'aggressive', or false to disable

  # Certname and machine name from cert. Work around broken networks.
  if is_domain_name($::clientcert) {
    $full_machine_name = split($::clientcert,'[.]')
    $machine_name = $full_machine_name[0]
  }
  else {
    $machine_name = $::clientcert
  }

  # r10k setup for architect classes
  $r10k_remote  = '/root/environments'
  $r10k_basedir = "${confdir}/environments"

  # is this a student's tier3 agent in Architect?
  if $::fqdn =~ /^\S+\.\S+\.puppetlabs\.vm$/ {
    $role = 'tier3'
  }
  else {
    $role = $::hostname ? {
      /^master|classroom|puppetfactory$/ => 'master',
      'proxy'                            => 'proxy',
      'adserver'                         => 'adserver',
      default                            => 'agent'
    }
  }

  $download = "\n\nPlease download a new VM: http://downloads.puppetlabs.com/training"
  if $role == 'master' {
    if versioncmp(pick($::pe_server_version, $::pe_version), '3.8.0') < 0 {
      fail("Your Puppet Enterprise installation is out of date. ${download}/puppet-training.ova/\n\n")
    }
    # we expect instructors to have newer VMs. The student machine can be older.
    if $::classroom_vm_release and versioncmp($::classroom_vm_release, '2.25') < 0 {
      fail("Your VM is out of date. ${download}/puppet-training.ova/\n\n")
    }
  }
  else {
    if $::classroom_vm_release and versioncmp($::classroom_vm_release, '2.17') < 0 {
      fail("Your VM is out of date. ${download}/puppet-student.ova/\n\n")
    }
  }
}

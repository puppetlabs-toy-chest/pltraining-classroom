class classroom::master::deployer (
  $password = $classroom::params::password,
) inherits classroom::params {
  assert_private('This class should not be called directly')

  rbac_user {'deployer':
    ensure       => present,
    display_name => 'deployer',
    email        => 'deployer@puppetlabs.vm',
    password     => $password,
    roles        => 4,
  }

  exec { 'create token':
    command  => "echo '${password}' | HOME=/root /opt/puppetlabs/bin/puppet-access login deployer --lifetime 1y",
    path     => '/bin:/usr/bin:/opt/puppetlabs/bin',
    creates  => '/root/.puppetlabs/token',
    provider => 'posix',
    require  => Rbac_user['deployer'],
  }

  if $::code_manager_enabled {
    file { '/etc/puppetlabs/code-staging/.deployed':
      ensure => file,
      owner  => 'pe-puppet',
      group  => 'pe-puppet',
      mode   => '0644',
      before => Exec['deploy codebase'],
    }

    # We run the deploy command on each Puppet run until the deployment succeeds.
    # This should never show up as a failed run.
    exec { 'deploy codebase':
      command => 'puppet code deploy --all --wait',
      path    => '/bin:/usr/bin:/opt/puppetlabs/bin',
      creates => '/etc/puppetlabs/code/.deployed',
      returns => [ 0, 1 ], # we "don't care" if it succeeds, just keep trying until it deploys
      require => Exec['create token'],
    }
  }

}

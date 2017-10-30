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

  exec { 'deploy codebase':
    command     => 'puppet code deploy --all --wait',
    path        => '/bin:/usr/bin:/opt/puppetlabs/bin',
    refreshonly => true,
    subscribe   => Exec['create token'],
  }
}


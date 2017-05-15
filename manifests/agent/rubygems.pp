class classroom::agent::rubygems (
  Boolean $offline = false,
) {
  if !$offline {
    # When online, simple package resources work fine
    package { [ 'rspec-puppet', 'puppetlabs_spec_helper' ]:
      ensure   => present,
      provider => 'puppet_gem',
    }

    package { 'serverspec':
      ensure   => present,
      provider => 'gem',
    }
  } else {
    # When offline, install gems from the /var/cache/rubygems directory,
    # and install them in the order listed here
    $rspec_puppet_gems = [ 'diff-lcs', 'rspec-support', 'rspec-mocks', 'rspec-expectations', 'rspec-core', 'rspec', 'rspec-puppet' ]
    offline_gem_installer($rspec_puppet_gems, 'puppet_gem')

    $psh_gems = [ 'metaclass', 'mocha', 'puppet-syntax', 'puppet-lint', 'puppetlabs_spec_helper' ]
    offline_gem_installer($psh_gems, 'puppet_gem')

    $serverspec_gems = [ 'sfl', 'net-telnet', 'net-scp', 'specinfra', 'multi_json', 'rspec-its', 'serverspec' ]
    offline_gem_installer($serverspec_gems, 'gem')
  }
}

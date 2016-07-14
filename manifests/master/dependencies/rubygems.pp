class classroom::master::dependencies::rubygems {
  assert_private('This class should not be called directly')

  # These are required by rubygems compiling native code
  package { ['gcc', 'zlib-devel']:
    ensure => present;
  }

  # these are used for various scripts
  package { ['puppetdb-ruby', 'colorize']:
    ensure   => present,
    provider => puppet_gem,
  }
}

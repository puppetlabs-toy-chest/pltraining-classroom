class classroom::master::dependencies::rubygems {
  assert_private('This class should not be called directly')

  # These are required by rubygems compiling native code
  package { ['gcc', 'zlib', 'zlib-devel']:
    ensure => present,
  }

  # these are used for various scripts
  package { ['puppetdb-ruby', 'colorize', 'puppetclassify']:
    ensure   => present,
    provider => puppet_gem,
  }
  
  # The new nokogiri won't run on RHEL or CentOS. Because reasons.
  # https://github.com/sparklemotion/nokogiri/blob/master/CHANGELOG.md#170--2016-12-26
  package { 'nokogiri':
    ensure   => '1.6.8.1',
    provider => gem,
  }
  # This is a soft relationship. It won't fail if showoff isn't included.
  Package['nokogiri'] -> Package<| title == 'showoff' |>
  
}

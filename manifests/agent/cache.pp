# Ensures that all offline agents have access to cached modules
#
# Warning: Do not use in production - this is a hack specifically for
# puppetlabs training courses
#
# Use:
#   Classify all agent nodes
#
class classroom::agent::cache (

  #This variable should configure Puppet to use the local cache.
  $offline_bmp_line = 'basemodulepath = /etc/puppetlabs/code/modules:/opt/puppetlabs/puppet/modules:/usr/src/forge'

) {
  assert_private('This class should not be called directly')

  if $::kernel =~ /Linux/ {
    if $::classroom::offline {
      file_line { 'add module cache to basemodulepath' :
        ensure  => present,
        path    => '/etc/puppetlabs/puppet/puppet.conf',
        line    => $offline_bmp_line,
        after   => '/\[main\]/',
        match   => '/^\s*basemodulepath\s*=/',
        replace => true,
      }
  } else {
      file_line { 'remove module cache from basemodulepath' :
        ensure => absent,
        path   => '/etc/puppetlabs/puppet/puppet.conf',
        line   => $offline_bmp_line,
      }
  }

}

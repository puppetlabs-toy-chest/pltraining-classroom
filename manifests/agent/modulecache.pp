#This module leverages the fact that we can add /usr/src/forge to our base-
# modulepath to automagically account for offline classes. 
#
class classroom::agent::modulecache (
  $config      = '/etc/puppetlabs/puppet/puppet.conf',
  $offline_bmp = '/etc/puppetlabs/code/modules:/usr/src/forge:/opt/puppetlabs/puppet/modules/',
) {
  assert_private('This class should not be called directly')
  
  $ensure = $::classroom::offline ? {
    true    => 'present',
    default => 'absent',
  }

  case $::kernel {
  
    'linux' : {
      ini_setting { "offline basemodulepath" :
        ensure  => $ensure,
        path    => $config,
        section => 'main',
        setting => 'basemodulepath',
        value   => $offline_bmp,
      }
    }

    # We don't have modules cached for Windows yet.
    default : {}

  }
}

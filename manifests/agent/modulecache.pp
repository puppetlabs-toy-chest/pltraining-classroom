#This module leverages the fact that we can add /usr/src/forge to our base-
# modulepath to automagically account for offline classes. 
#
class classroom::agent::modulecache (
  $config = '/etc/puppetlabs/puppet/puppet.conf',
  $offline_bmp = '/etc/puppetlabs/code/modules:/usr/src/forge:/opt/puppetlabs/puppet/modules/',
) {

  case $::kernel {

    'linux' : {

      case $::classroom::offline {
        true  : {
          $ensure = 'present'
          $type  = 'offline'
        }
        default : {
          $ensure = 'absent'
          $type  = 'online'
        }
      }

      ini_setting { "basemodulepath configured for ${type} instruction" :
        ensure  => $ensure,
        path    => $config,
        section => 'main',
        setting => 'basemodulepath',
        value   => $offline_bmp,
      }


    }

    default : {}

  }

}

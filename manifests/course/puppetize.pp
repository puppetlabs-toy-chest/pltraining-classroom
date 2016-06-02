# This is a wrapper class to include all the bits needed for Puppetizing infrastructure
#
class classroom::course::puppetize (
  $offline      = $classroom::params::offline,
  $manageyum    = $classroom::params::manageyum,
  $time_servers = $classroom::params::time_servers,
) inherits classroom::params {
  include puppetfactory::profile::puppetize
  if $::osfamily == 'Windows' {
    windows_env { 'PATH=C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin': }
  }
}

# Ensures that all offline agents have required modules cached
#
# Warning: Do not use in production - this is a hack specifically for
# puppetlabs training courses
#
# Use:
#   Classify all agent nodes
#
class classroom::agent::cache (
  $cachedir = '/usr/src/forge',
  $moduledir = "${::classroom::params::codedir}/modules",
) inherits classroom::params {
  assert_private('This class should not be called directly')

  if $::kernel =~ /Linux/ and $::classroom::offline {
    exec { 'Copy cached modules for offline use' :
      command   => "rsync -aP  ${cachedir}/ ${moduledir}/",
      path      => '/usr/bin/',
      creates   => "${moduledir}/wsus_client",
      logoutput => 'on_failure',
    }

  }


}

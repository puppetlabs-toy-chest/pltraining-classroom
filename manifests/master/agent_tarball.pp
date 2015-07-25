# Configure the classroom so that any secondary masters will get the
# agent tarball from the classroom master.
class classroom::master::agent_tarball {
  assert_private('This class should not be called directly')

  $version   = pick($::pe_server_version, $::pe_version)
  $cachedir  = $classroom::params::cachedir
  $publicdir = $classroom::params::publicdir

  if versioncmp($::pe_version, '3.4.0') >= 0 {
    $filename = "puppet-enterprise-${version}-${::platform_tag}-agent.tar.gz"
    $download = "https://pm.puppetlabs.com/puppet-enterprise/${version}/${filename}"

    file { [$publicdir, "${publicdir}/${version}"]:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    pe_staging::file { "${cachedir}/${filename}":
      source => $download,
      target => "${cachedir}/${filename}",
      before => File["${publicdir}/${version}/${filename}"],
    }

    file { "${publicdir}/${version}/${filename}":
      ensure => file,
      source => "${cachedir}/${filename}",
    }
  }
}

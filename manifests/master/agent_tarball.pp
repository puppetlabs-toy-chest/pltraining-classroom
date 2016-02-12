# Configure the classroom so that any secondary masters will get the
# agent tarball from the classroom master.
class classroom::master::agent_tarball {
  assert_private('This class should not be called directly')

  $cachedir  = $classroom::params::cachedir
  $publicdir = $classroom::params::publicdir

  # https://pm.puppetlabs.com/puppet-agent/2015.2.0/1.2.2/repos/puppet-agent-el-6-x86_64.tar.gz
  $filename    = "puppet-agent-${::platform_tag}.tar.gz"
  $download    = "https://pm.puppetlabs.com/puppet-agent/${pe_server_version}/${aio_agent_version}/repos/${filename}"
  $destination = "${publicdir}/classroom/${pe_server_version}/${aio_agent_version}/repos"

  dirtree { $destination:
    path    => $destination,
    ensure  => present,
    parents => true,
  }

  file { $destination:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  pe_staging::file { "${cachedir}/${filename}":
    source => $download,
    target => "${cachedir}/${filename}",
    before => File["${destination}/${filename}"],
  }

  file { "${destination}/${filename}":
    ensure => file,
    source => "${cachedir}/${filename}",
  }
}

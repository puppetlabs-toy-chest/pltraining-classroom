# This is a temporary hack to make sure that student masters have a
# production environment created. We will revisit this post PE3.7 release
#
class classroom::master::student_environment {
  assert_private('This class should not be called directly')

  $environmentpath = "${classroom::codedir}/environments"
  $environmentname = 'production'
  $environment     = "${environmentpath}/${environmentname}"

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Dirtree['environment path'],
  }

  # We cannot assume this directory exists, but we need to put files in it.
  dirtree { 'environment path':
    ensure  => present,
    path    => $environmentpath,
    parents => true,
  }

  file { [
    $environment,
    "${environment}/manifests",
    "${environment}/modules",
  ]:
    ensure => directory,
  }

  # This is a copy of site.pp used for the architect class
  file { "${environment}/manifests/site.pp":
    ensure  => file,
    source  => 'puppet:///modules/classroom/site-architect.pp',
    replace => false,
  }

  # We only want to write this once so it isn't confusing later on.
  unless ($::puppetlabs_class) {
    # intentionally broken example code
    file { "${environment}/modules/cowsay":
      ensure  => directory,
      source  => 'puppet:///modules/classroom/example/cowsay',
      replace => false,
      recurse => true,
    }
  }

  # Ensure the environment cache is disabled and restart if needed
  ini_setting {'environment_timeout':
    ensure  => present,
    path    => "${classroom::confdir}/puppet.conf",
    section => 'main',
    setting => 'environment_timeout',
    value   => '0',
  }

  # Ensure the environmentpath is configured and restart if needed
  ini_setting {'environmentpath':
    ensure  => present,
    path    => "${classroom::confdir}/puppet.conf",
    section => 'main',
    setting => 'environmentpath',
    value   => $environmentpath,
  }

  # mitigate PE-11356
  if $::pe_server_version == '2015.2.0' {
    pe_ini_setting { 'puppetserver puppetconf user':
      setting => 'user',
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      value   => 'pe-puppet',
      section => 'main'
    }

    pe_ini_setting { 'puppetserver puppetconf group':
      setting => 'group',
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      value   => 'pe-puppet',
      section => 'main'
    }

    # mitigate PE-11366
    dirtree { '/opt/puppetlabs/server':
      ensure => present,
      path   => '/opt/puppetlabs/server',
    }
    file { '/opt/puppetlabs/server/pe_build':
      ensure  => file,
      content => '2015.2.0',
    }

  }
}

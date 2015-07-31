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

  file { "${environment}/manifests/site.pp":
    ensure  => file,
    source  => 'puppet:///modules/classroom/site.pp',
    replace => false,
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

  # mitigate PE-11366
  dirtree { '/opt/puppetlabs/server':
    path   => '/opt/puppetlabs/server',
    ensure => present,
  }
  file { '/opt/puppetlabs/server/pe_build':
    ensure  => file,
    content => '2015.2.0',
  }
}

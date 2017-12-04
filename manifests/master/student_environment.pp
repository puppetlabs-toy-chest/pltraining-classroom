# This is a temporary hack to make sure that student masters have a
# production environment created. We will revisit this post PE3.7 release
#
class classroom::master::student_environment {
  assert_private('This class should not be called directly')

  $environmentpath = "${classroom::codedir}/environments"
  $environmentname = 'production'
  $environment     = "${environmentpath}/${environmentname}"

  File {
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
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

  # We only want to write this once so it isn't confusing later on.
  unless ($::puppetlabs_class) {
    # This is a copy of site.pp used for the architect class
    file { "${environment}/manifests/site.pp":
      ensure  => file,
      source  => 'puppet:///modules/classroom/site-architect.pp',
      replace => false,
    }

    # intentionally broken example code
    file { "${environment}/modules/cowsay":
      ensure  => directory,
      source  => 'puppet:///modules/classroom/example/cowsay',
      replace => false,
      recurse => true,
    }
  }

}

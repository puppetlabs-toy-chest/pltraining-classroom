# This Class sets up the docker environment and containers for
# the Infrastructure course
#
class classroom::course::infrastructure (
  $training_password = $classroom::params::training_password
) inherits classroom::params {
  include classroom::virtual
  
  $containers = {
    'test.puppetlabs.vm'  => ['10080:80'],
    'web1.puppetlabs.vm'  => ['20080:80'],
    'db2dev.puppetlabs.vm' => ['30080:80'],
    'web2dev.puppetlabs.vm' => ['40080:80'],
  }

  $containers.each |$container_name,$ports| {
    dockeragent::node { $container_name:
      ports      => $ports,
      privileged => true,
    }
  }

  # Install the course_selector module from github
  vcsrepo { '/etc/puppetlabs/code/modules/course_selector':
    ensure   => present,
    provider => 'git',
    source   => 'http://github.com/puppetlabs/pltraining-course_selector',
  }

  # Grab the script for the course_selector, which will install the other scripts
  file { '/usr/local/bin/course_selector':
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/course_selector/scripts/course_selector.rb',
    require => Vcsrepo['/etc/puppetlabs/code/modules/course_selector'],
  }

  user { 'training':
    ensure   => present,
    password => $training_password,
  }

  class {'abalone':
    port => '80'
  }

}

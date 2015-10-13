# This class writes out some moderately interesting external facts. These are
# useful for demonstrating structured facts.
#
# Their existence also serves as a marker that initial provisioning has taken
# place, for the small handful of items that we only want to manage once.
#
class classroom::facts (
  $coursename,
  $role = $classroom::params::role,
) inherits classroom::params {

  if $::osfamily == 'windows' {
    file {'C:\ProgramData\PuppetLabs\facter\fact.d':
      ensure => directory,
    }
    file { 'C:\ProgramData\PuppetLabs\facter\fact.d\puppetlabs.txt':
      ensure  => file,
      content => template('classroom/facts.txt.erb'),
    }
  }
  else {
    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }
    file { [ '/etc/puppetlabs/facter/', '/etc/puppetlabs/facter/facts.d/' ]:
      ensure => directory,
    }
    file { '/etc/puppetlabs/facter/facts.d/puppetlabs.txt':
      ensure  => file,
      content => template('classroom/facts.txt.erb'),
    }
  }
}

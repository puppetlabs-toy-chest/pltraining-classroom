# Create a few scripts useful for working with reports. These are
# primarily used for the Practitioner course at this point.
class classroom::master::reporting_tools {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0777',
  }

  file { '/usr/local/bin/get_environment_version.sh':
    ensure => file,
    source => 'puppet:///modules/classroom/get_environment_version.sh',
  }

  # this gives me a sad. We need some refactoring. Serious refactoring.
  if ! defined(File['/usr/local/bin/process_reports.rb']) {
    file { '/usr/local/bin/process_reports.rb':
      ensure => file,
      source => 'puppet:///modules/classroom/process_reports.rb',
    }
  }
}

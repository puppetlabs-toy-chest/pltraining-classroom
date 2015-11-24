# This is an intentionally broken example class.
# Correct the typo to move on.
class cwosay {
  $message = 'Welcome to Puppet Architect!'

  package { 'cowsay':
    ensure   => present,
  }
  exec { 'cowsay':
    command   => "/usr/bin/cowsay '${message}'",
    require   => Package['cowsay'],
    logoutput => true,
  }
}

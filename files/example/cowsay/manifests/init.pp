# This is an intentionally broken example class.
# Correct the typo to move on.
class cwosay {
  $message = 'Welcome to Puppet Architect!'

  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }
  exec { 'cowsay':
    command   => "cowsay '${message}'",
    path      => '/usr/bin:/usr/local/bin',
    require   => Package['cowsay'],
    logoutput => true,
  }
}

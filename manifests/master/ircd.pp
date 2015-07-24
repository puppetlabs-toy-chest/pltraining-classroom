# Simple and inflexible IRCd setup for the classroom
class classroom::master::ircd {
  assert_private('This class should not be called directly')

  package { 'ngircd':
    ensure => present,
  }

  file { '/etc/ngircd.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/ngircd.conf.erb"),
  }

  service { 'ngircd':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/ngircd.conf'],
  }

  # gems used by the irc report handler.
  package { 'carrier-pigeon':
    ensure   => present,
    provider => $aio_agent_version ? {
      undef   => pe_puppetserver_gem,
      default => puppetserver_gem,
    },
  }

}

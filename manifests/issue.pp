class classroom::issue {
  # Ensure the IP address displayed on the console splash screen is current
  if $osfamily != 'Windows' {
    file { '/etc/issue':
      ensure => file,
    }
    file_line { 'update ipaddress in /etc/issue':
      path    => '/etc/issue',  
      line    => "    IP: ${ipaddress}",
      match   => "^    IP:.*$",
      require => File['/etc/issue'],
    }
  } 
}

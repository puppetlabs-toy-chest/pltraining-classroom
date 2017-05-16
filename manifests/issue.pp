class classroom::issue {

if $osfamily != 'Windows' {
  file { '/etc/issue':
    ensure => file,
    before => File_line['update ipaddress in /etc/issue'],
  }
  file_line { 'update ipaddress in /etc/issue':
    path => '/etc/issue',  
    line => "    IP: ${ipaddress}",
    match   => "^    IP:.*$",
    }
  } 
}

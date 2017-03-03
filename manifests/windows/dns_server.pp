# Set a DNS server on the windows agents
define classroom::windows::dns_server (
  $adserver_ip = 'facts[value]{name = "ipaddress" and certname = "adserver"},
  $ip = '8.8.8.8',
) {
    # Only run on windows
    if $::osfamily  == 'windows' {
      exec { 'set_dns':
        command  => "set-DnsClientServerAddress -interfacealias Ethernet0 -serveraddresses ${adserver_ip[0][value]}, ${ip}",
        unless   => "if ((Get-DnsClientServerAddress -addressfamily ipv4 -interfacealias Ethernet0).serveraddresses -notcontains '${adserver_ip[0][value]}'){exit 1}",
        provider => powershell,
      }
    }
}

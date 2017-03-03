# Set a DNS server on the windows agents
define classroom::windows::dns_server (
  $adserver_ip_query = 'facts[value]{name = "ipaddress" and certname = "adserver"}',
  $adserver_ip_lookup = puppetdb_query($adserver_ip_query)
  $ip = '8.8.8.8',
) {
  $adserver_ip = $adserver_ip_lookup ? {
    Array   => $adserver_ip_lookup[0][value],
    default => '8.8.4.4',
    }
    # Only run on windows
    if $::osfamily  == 'windows' {
      exec { 'set_dns':
        command  => "set-DnsClientServerAddress -interfacealias Ethernet0 -serveraddresses ${adserver_ip}, ${ip}",
        unless   => "if ((Get-DnsClientServerAddress -addressfamily ipv4 -interfacealias Ethernet0).serveraddresses -notcontains '${adserver_ip}'){exit 1}",
        provider => powershell,
      }
    }
}

class classroom::windows::enable_rdp {
  assert_private('This class should not be called directly')

  registry_value { 'hklm\System\CurrentControlSet\Control\Terminal Server\fDenyTSConnections':
    ensure => present,
    type   => 'dword',
    data   => '0',
  }
  registry_value { 'hklm\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\UserAuthentication':
    ensure => present,
    type   => 'dword',
    data   => '1',
  }

  exec { 'Enable RDP firewall rule':
    command  => 'Enable-NetFirewallRule -DisplayGroup "Remote Desktop"',
    onlyif   => 'if (((New-Object -ComObject hnetcfg.fwpolicy2).rules | Where-Object {$_.Name -like "Remote Desktop*User*TCP*"}).enabled) { exit 1 }',
    provider => 'powershell',
  }
}

# Make sure the windows setup files are on the master for the students
# to download and configure the Windows Server for the installation of
# the puppet agent.

# Works similarly to curl | bash solution for linux with the following commands in powershell
# [System.Net.ServicePointManager]::ServerCertificateValidationCallback={$true}
# iex (New-Object System.Net.WebClient).DownloadString('https://ipaddress:8140/packages/current/setup_windows.ps1')

class classroom::master::windows {
  require pe_repo::platform::windows_x86_64
  assert_private('This class should not be called directly')

  $publicdir = $classroom::params::publicdir

  File {
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  $destination = "${publicdir}/current"

  file { "${destination}/setup_windows.ps1":
    source => "puppet:///modules/classroom/windows/setup_windows.ps1",
  }

  file { "${destination}/windows-x86_64/setup_classroom.ps1":
    source => "puppet:///modules/classroom/windows/setup_classroom.ps1",
  }
}

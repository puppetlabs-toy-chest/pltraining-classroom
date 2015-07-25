class classroom::windows::chocolatey {
  assert_private('This class should not be called directly')

  file { 'C:\install.ps1':
    source => 'puppet:///modules/classroom/install.ps1',
  }
  exec { 'install-chocolatey':
    command  => 'C:\install.ps1 >$null 2>&1',
    creates  => ['C:\Chocolatey','C:\ProgramData\chocolatey'],
    provider => powershell,
    timeout  => $classroom::params::timeout,
    require  => File['C:\install.ps1'],
  }
}

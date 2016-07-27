class classroom::windows::disable_esc {
  assert_private('This class should not be called directly')

  # Disable Internet Explorer ESC for users and admins, both
  registry::value { 'IE_ESC_users':
    key   => 'hklm\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}',
    value => 'IsInstalled',
    type  => dword,
    data  => '0',
  }
  registry::value { 'IE_ESC_admin':
    key   => 'hklm\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}',
    value => 'IsInstalled',
    type  => dword,
    data  => '0',
  }
  
  # The settings don't take effect without logging out or restarting explorer.
  # In general this is a code smell and should be avoided.
  # The only reason to do it here is to make things run smoothly in the classroom.
  exec { 'restart explorer to disable IEESC':
    command     => '$(Stop-Process -Name Explorer)',
    provider    => 'powershell',
    subscribe   => [Registry::Value['IE_ESC_users'], Registry::Value['IE_ESC_admin']],
    refreshonly => true,
  }
}

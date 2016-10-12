class classroom::windows::adserver {
  assert_private('This class should not be called directly')

  # Local administrator is required to have a password before AD will install
  exec { 'RequirePassword':
    command  => 'net user Administrator /passwordreq:yes',
    unless   => 'if (net user Administrator |select-string -pattern "Password required.*no"){exit 1}',
    provider => powershell,
  }

  # Install AD Server feature
#  dsc_windowsfeature { 'ADDSInstall':
#    dsc_ensure => 'Present',
#    dsc_name   => 'AD-Domain-Services',
#    require    => [Exec['RequirePassword'],Exec['Install WMF5']],
#  }

  exec { "add-feature-adserver":
    command   => "Import-Module ServerManager; Install-WindowsFeature AD-Domain-Services -IncludeManagementTools -IncludeAllSubFeature -Restart:\$true",
    onlyif    => "Import-Module ServerManager; if (@(Get-WindowsFeature AD-Domain-Services | ?{\$_.Installed -match \'false\'}).count -eq 0) { exit 1 }",
    provider  => powershell,
    before    => Exec['Config ADDS'],
  }

 # Setup Classroom Domain
#  dsc_xaddomain { 'FirstDS':
#    dsc_domainname                    => $classroom::ad_domainname,
#    dsc_domainadministratorcredential => {'user' => 'Administrator', 'password' => $classroom::ad_dsrmpassword },
#    dsc_safemodeadministratorpassword => {'user' => 'Administrator', 'password' => $classroom::ad_dsrmpassword },
#    require                           => Dsc_windowsfeature['ADDSInstall'],
#  }
#
#  reboot {'after_AD':
#    subscribe => Dsc_xaddomain['FirstDS'],
#    notify    => Dsc_xwaitforaddomain['DscForestWait'],
#  }
#
#  dsc_xwaitforaddomain { 'DscForestWait':
#    dsc_domainname           => $classroom::ad_domainname,
#    dsc_domainusercredential => {'user' => 'Administrator', 'password' => $classroom::ad_dsrmpassword },
#    dsc_retrycount           => '50',
#    dsc_retryintervalsec     => '30',
#    require                  => Dsc_xaddomain['FirstDS']
#  }
#

  exec { 'Config ADDS':
    command     => "Import-Module ADDSDeployment; Install-ADDSForest -Force -DomainName ${classroom::ad_domainname} -DomainMode 6 -DomainNetbiosName ${classroom::ad_netbiosdomainname} -ForestMode 6 -DatabasePath c:\\windows\\ntds -LogPath c:\\windows\\ntds -SysvolPath c:\\windows\\sysvol -SafeModeAdministratorPassword (convertto-securestring '${classroom::ad_dsrmpassword}' -asplaintext -force) -InstallDns",
    provider    => powershell,
    onlyif      => "if((gwmi WIN32_ComputerSystem).Domain -eq \'${classroom::ad_domainname}\'){exit 1}",
    timeout     => '0',
    before      => Exec['SetMachineQuota'],
  }

  reboot { 'after ADDS':
    subscribe => Exec['Config ADDS'],
  }

  # Increase the number of machines that a single user can join to the domain
  exec { 'SetMachineQuota':
    command      => 'get-addomain |set-addomain -Replace @{\'ms-DS-MachineAccountQuota\'=\'99\'}',
    unless       => 'if ((get-addomain | get-adobject -prop \'ms-DS-MachineAccountQuota\' | select -exp \'ms-DS-MachineAccountQuota\') -lt 99) {exit 1}',
    provider     => powershell,
    #    require => Dsc_xwaitforaddomain['DscForestWait'],
    require      => Reboot['after ADDS'],
  }

  exec { 'STUDENTS OU':
    command  => "import-module activedirectory;New-ADOrganizationalUnit -Name 'STUDENTS' -Path 'DC=CLASSROOM,DC=LOCAL' -ProtectedFromAccidentalDeletion \$true",
    onlyif   => "if([adsi]::Exists(\"LDAP://OU=STUDENTS,DC=CLASSROOM,DC=LOCAL\")){exit 1}",
    provider => powershell,
    require  => Exec['SetMachineQuota']
  }

#  dsc_xadgroup { 'WebsiteAdmins':
#    dsc_groupname => $title,
#    dsc_groupscope => 'Global',
#    dsc_description => 'Web Admins',
#    dsc_ensure      => 'Present',
#  }
  exec { 'Website Admins Group':
    command     => "import-module activedirectory;New-ADGroup -Description 'Website Administrators' -DisplayName 'WebAdmins' -Name 'WebAdmins' -GroupCategory 'Security' -GroupScope 'Global' -Path 'CN=Users,DC=CLASSROOM,DC=LOCAL'",
    onlyif      => "\$groupname = \"WebAdmins\";\$path = \"CN=Users,DC=CLASSROOM,DC=LOCAL\";\$oustring = \"CN=\$groupname,\$path\"; if([adsi]::Exists(\"LDAP://\$oustring\")){exit 1}",
    provider    => powershell,
    require     => Exec['STUDENTS OU'],
  }

#  dsc_xaduser { 'admin':
#    dsc_domainname                    => $classroom::ad_domainname,
#    dsc_domainadministratorcredential =>
#      {
#        'user' => 'Administrator',
#        'password' => $classroom::addsrmpassword,
#      },
#    dsc_username => 'admin',
#    dsc_password =>
#      {
#        'user' => 'admin',
#        'password' => 'M1Gr3atP@ssw0rd',
#      },
#    dsc_ensure => 'Present',
#    require => Dsc_xwaitforaddomain['DscForestWait']
#  }

  exec { "Add User - admin":
    command     => "import-module servermanager;add-windowsfeature -name 'rsat-ad-powershell' -includeAllSubFeature;import-module activedirectory;New-ADUser -name 'Classroom Admin' -DisplayName 'Classroom Admin' -GivenName 'Classroom' -SurName 'Admin' -Email 'admin@CLASSROOM.local' -Samaccountname 'admin' -UserPrincipalName 'admin@CLASSROOM.local' -Description 'Classroom Administrator' -PasswordNeverExpires \$true -path 'OU=STUDENTS,DC=CLASSROOM,DC=local' -AccountPassword (ConvertTo-SecureString 'Adm1nP@SSw0rd' -AsPlainText -force) -Enabled \$true;",
    onlyif      => "\$oustring = \"CN=Classroom Admin,OU=STUDENTS,DC=CLASSROOM,DC=local\"; if([adsi]::Exists(\"LDAP://\$oustring\")){exit 1}",
    provider    => powershell,
    require     => Exec['STUDENTS OU'],
  }

  # Download install for brackets lab
  class { 'staging':
    path    => 'C:/shares',
  }
  staging::file { 'Brackets.msi':
    source  => 'https://github.com/adobe/brackets/releases/download/release-1.3/Brackets.Release.1.3.msi',
    require => Class['staging'],
  }

  # Windows file share for UNC lab

  fileshare { 'installer':
    ensure  => present,
    path    => 'C:/shares/classroom',
    require => Class['staging'],
  }

  acl { 'c:/shares/classroom/Brackets.msi':
    permissions => [
      { identity => 'Administrator', rights => ['full'] },
      { identity => 'Everyone',      rights => ['read','execute'] },
    ],
    require     => Staging::File['Brackets.msi'],
  }

}

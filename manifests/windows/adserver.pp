class classroom::windows::adserver (
  $ad_domainname = $classroom::params::ad_domainname,
  $ad_dsrmpassword = $classroom::params::ad_dsrmpassword,
) inherits classroom::params {

	# This class will configure an Active Directory server, and also set up a fileshare to host an installer
  # for a lab. This will require two (automatic) reboots, once after installing WMF5 (Powershell 5), and
  # another immediately after setting up an AD domain, for the server to join the domain.

  assert_private('This class should not be called directly')

	# This will get us WMF5, which is required for DSC to work.
  # Pinning to a version, can change this to a more recent version in the future after testing.
	package { 'powershell':
  	ensure => '5.1.14409.20170510',
  	provider => 'chocolatey',
  }

	# We need a reboot before DSC can use WMF5.
	reboot { 'after_powershell':
  	subscribe => Package['powershell'],
	}

	exec { 'RequirePassword':
		command  => 'net user Administrator /passwordreq:yes',
		unless   => 'if (net user Administrator |select-string -pattern "Password required.*no"){exit 1} else {exit 0}',
		provider => powershell,
	}

	dsc_windowsfeature { 'ADDSInstall':
		dsc_ensure => 'Present',
		dsc_name   => 'AD-Domain-Services',
		require    => [Exec['RequirePassword'],Package['powershell']],
	}

	dsc_xaddomain { 'FirstDS':
		dsc_domainname                    => $ad_domainname,
		dsc_domainadministratorcredential => {'user' => 'Administrator', 'password' => $ad_dsrmpassword },
		dsc_safemodeadministratorpassword => {'user' => 'Administrator', 'password' => $ad_dsrmpassword },
		require                           => Dsc_windowsfeature['ADDSInstall'],
		notify                            => Reboot['after_ad_domain'],
	}

	# This reboot needs to be immediate. Using DSC's recommended 'pending' reboot doesn't do it.
	reboot {'after_ad_domain':
		message => 'We set up a Domain, and so we have to reboot',
		apply   => 'immediately',
	}

	exec { 'SetMachineQuota':
		command      => 'get-addomain |set-addomain -Replace @{\'ms-DS-MachineAccountQuota\'=\'99\'}',
		unless       => 'if ((get-addomain | get-adobject -prop \'ms-DS-MachineAccountQuota\' | select -exp \'ms-DS-MachineAccountQuota\') -lt 99) {exit 1} else {exit 0}',
		provider     => powershell,
		require => Dsc_xaddomain['FirstDS'],
	}

	exec { 'STUDENTS OU':
		command  => "import-module activedirectory;New-ADOrganizationalUnit -Name 'STUDENTS' -Path 'DC=CLASSROOM,DC=LOCAL' -ProtectedFromAccidentalDeletion \$true",
		onlyif   => "if([adsi]::Exists(\"LDAP://OU=STUDENTS,DC=CLASSROOM,DC=LOCAL\")){exit 1} else {exit 0}",
		provider => powershell,
		require  => Exec['SetMachineQuota']
	}

	dsc_xadgroup { 'WebsiteAdmins':
		dsc_groupname => 'WebsiteAdmins',
		dsc_groupscope => 'Global',
		dsc_description => 'Web Admins',
		dsc_ensure      => 'Present',
		require => Dsc_xaddomain['FirstDS'],
	}

	dsc_xaduser { 'admin':
		dsc_domainname => $ad_domainname,
		dsc_domainadministratorcredential =>
		{
			'user' => 'Administrator',
			'password' => $ad_dsrmpassword,
		},
		dsc_username => 'admin',
		dsc_password =>
		{
			'user' => 'admin',
			'password' => 'M1Gr3atP@ssw0rd',
		},
		dsc_ensure => 'present',
		require => Dsc_xaddomain['FirstDS'],
	}

  # Download install for brackets lab
  file { ['C:/shares', 'C:/shares/classroom']:
    ensure => directory,
  }

  archive { 'C:/shares/Brackets.msi':
    source  => 'https://github.com/adobe/brackets/releases/download/release-1.3/Brackets.Release.1.3.msi',
    require => File['C:/shares'],
  }

  # Windows file share for UNC lab

  fileshare { 'installer':
    ensure  => present,
    path    => 'C:/shares/classroom',
    require => File['C:/shares/classroom'],
  }

  acl { 'c:/shares/classroom/Brackets.msi':
    permissions => [
      { identity => 'Administrator', rights => ['full'] },
      { identity => 'Everyone',      rights => ['read','execute'] },
    ],
    require     => Staging::File['Brackets.msi'],
  }

}

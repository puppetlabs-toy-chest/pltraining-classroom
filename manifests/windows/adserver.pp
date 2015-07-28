class classroom::windows::adserver {
  assert_private('This class should not be called directly')

  class { 'windows_ad' :
    install                => present,
    installmanagementtools => true,
    restart                => true,
    installflag            => true,
    configure              => present,
    configureflag          => true,
    domaintype             => 'Forest',
    domain                 => 'forest',
    domainname             => $classroom::ad_domainname,
    netbiosdomainname      => $classroom::ad_netbiosdomainname,
    domainlevel            => '6',
    forestlevel            => '6',
    installtype            => 'domain',
    installdns             => 'no',
    dsrmpassword           => $classroom::ad_dsrmpassword,
    require                => Exec['RequirePassword'],
  }
  # Local administrator is required to have a password before AD will install
  exec { 'RequirePassword':
    command  => 'net user Administrator /passwordreq:yes',
    unless   => 'if (net user Administrator |select-string -pattern "Password required.*no"){exit 1}',
    provider => powershell,
  }

  # Increase the number of machines that a single user can join to the domain
  exec { 'SetMachineQuota':
    command  => 'get-addomain |set-addomain -Replace @{\'ms-DS-MachineAccountQuota\'=\'99\'}',
    unless   => 'if ((get-addomain | get-adobject -prop \'ms-DS-MachineAccountQuota\' | select -exp \'ms-DS-MachineAccountQuota\') -lt 99) {exit 1}',
    provider => powershell,
    require  => Class['windows_ad'],
  }

  # Download install for brackets lab
  class { 'staging':
    path    => 'C:/shares/',
    require => Class['windows_ad'],
  }
  staging::file { 'Brackets.msi':
    source  => 'https://github.com/adobe/brackets/releases/download/release-1.3/Brackets.Release.1.3.msi',
    require => Class['staging'],
  }

  # Windows file share for UNC lab
  fileshare { 'installer':
    ensure  => present,
    path    => 'C:\shares\classroom',
    require => Class['staging'],
  }
  acl { 'c:/shares/classroom/Brackets.msi':
    permissions => [
      { identity => 'Administrator', rights => ['full'] },
      { identity => 'Everyone',      rights => ['read','execute'] },
    ],
    require     => Staging::File['Brackets.msi'],
  }

  # Export AD server IP to be DNS server for agents
  @@classroom::windows::dns_server { 'primary_ip':
    ip => $::ipaddress,
  }
  # Add "CLASSROOM\admin" user to domain
    # Create OU for classroom
  windows_ad::organisationalunit{'STUDENTS':
    ensure  => present,
    path    => 'DC=CLASSROOM,DC=LOCAL',
    ouName  => 'STUDENTS',
    require => Class['windows_ad'],
  }
  windows_ad::group{'WebsiteAdmins':
    ensure        => present,
    path          => 'CN=Users,DC=CLASSROOM,DC=LOCAL',
    groupname     => 'WebsiteAdmins',
    groupscope    => 'Global',
    groupcategory => 'Security',
    description   => 'Web Admins',
  }
  # Add "CLASSROOM\admin" user to domain
  windows_ad::user{'admin':
    ensure               => present,
    domainname           => 'CLASSROOM.local',
    path                 => 'OU=STUDENTS,DC=CLASSROOM,DC=local',
    accountname          => 'admin',
    lastname             => 'Admin',
    firstname            => 'Classroom',
    passwordneverexpires => true,
    passwordlength       => 15,
    password             => 'M1Gr3atP@ssw0rd',
    emailaddress         => 'admin@CLASSROOM.local',
    require              => Windows_ad::Organisationalunit['STUDENTS'],
  }
}

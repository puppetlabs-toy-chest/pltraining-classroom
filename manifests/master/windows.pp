# Make sure the windows setup files are on the master for the students
# to download and configure the Windows Server for the installation of
# the puppet agent.
class classroom::master::windows {
  assert_private('This class should not be called directly')

  $publicdir = $classroom::params::publicdir

  File {
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  $destination = "${publicdir}/${pe_server_version}/windows-x86_64"

  file { "${destination}/setup_windows.ps1":
    source => "puppet:///modules/classroom/windows/setup_windows.ps1",
  }

  file { "${destination}/setup_classroom.ps1":
    source => "puppet:///modules/classroom/windows/setup_classroom.ps1",
  }
}

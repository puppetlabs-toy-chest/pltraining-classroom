class classroom::windows::rubygems_update {
  assert_private('This class should not be called directly')

  Exec {
    path => 'c:/windows/sysnative;c:/windows/system32;C:/Program Files/Puppet Labs/Puppet/sys/ruby/bin',
  }

  # yes, this makes me sad too
  unless versioncmp($::rubygems_version, '2.6.7') >= 0 {
    exec { 'cmd.exe /c gem sources -r https://rubygems.org/': }
    -> exec { 'cmd.exe /c gem sources -a http://rubygems.org/': } # doesn't work yet, it prompts for confirmation

    -> exec { 'cmd.exe /c gem update --system': }

    -> exec { 'cmd.exe /c gem sources -r http://rubygems.org/': }
    -> exec { 'cmd.exe /c gem sources -a https://rubygems.org/': }
  }
}

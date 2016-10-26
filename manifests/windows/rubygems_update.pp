class classroom::windows::rubygems_update {
  assert_private('This class should not be called directly')

  # yes, this makes me sad too
  unless versioncmp($::rubygems_version, '2.6.7') >= 0 {
    file { 'C:/Users/Administrator/.gemrc':
      owner  => 'Administrator',
      group  => 'Administrators',
      mode   => '0644',
      source => 'puppet:///modules/classroom/windows/gemrc',
    }

    File['C:/Users/Administrator/.gemrc'] -> Package<| provider == gem |>

# the rubygems update doesn't seem to work. Let's just disable https completely for now.
#     exec { 'cmd.exe /c gem update --system':
#       path    => 'c:/windows/sysnative;c:/windows/system32;C:/Program Files/Puppet Labs/Puppet/sys/ruby/bin',
#       require => File['C:/Users/Administrator/.gemrc'],
#     }
  }
}

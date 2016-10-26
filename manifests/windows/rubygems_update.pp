class classroom::windows::rubygems_update {
  assert_private('This class should not be called directly')

  Exec {
    path => 'C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin',
  }

  # yes, this makes me sad too
  unless versioncmp($::rubygems_version, '2.6.7') >= 0 {
    exec { 'gem sources -r https://rubygems.org/': }
    -> exec { 'gem sources -a http://rubygems.org/': }

    -> exec { 'gem update --system': }

    -> exec { 'gem sources -r http://rubygems.org/': }
    -> exec { 'gem sources -a https://rubygems.org/': }
  }
}

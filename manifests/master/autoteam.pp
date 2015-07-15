# Paramters:
# * $autoteam: automatically create simple teams for Capstone. Defaults to false.
#
class classroom::master::autoteam {
  assert_private('This class should not be called directly')

  if $classroom::autoteam {
    file { "${classroom::codedir}/hieradata/teams.yaml":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('classroom/teams.yaml.erb'),
      replace => false,
    }
  }
}

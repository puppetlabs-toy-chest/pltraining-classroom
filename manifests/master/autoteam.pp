# Paramters:
# * $autoteam: automatically create simple teams for Capstone. Defaults to false.
#
class classroom::master::autoteam (
  $autoteam = $classroom::autoteam,
) inherits classroom {
  validate_bool($autoteam)

  if $autoteam {
    file { '/etc/puppetlabs/puppet/hieradata/teams.yaml':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('classroom/teams.yaml.erb'),
      replace => false,
    }
  }
}

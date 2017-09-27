class classroom::gemrc (
  Boolean $offline = false,
) {
  # NOTE: this online version of the .gemrc should match the one in pltraining-bootstrap

  if $::osfamily == 'windows' {
    file { ['C:/Users/Administrator/.gemrc', 'C:/ProgramData/PuppetLabs/puppet/etc/.gemrc' ]:
      ensure  => file,
      owner   => 'Administrator',
      group   => 'Administrators',
      mode    => '0644',
      content => epp('classroom/gemrc.epp', { offline => $offline }),
    }
  }
  else {
    file { '/opt/puppetlabs/puppet/etc':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    file { ['/root/.gemrc', '/.gemrc', '/etc/gemrc', '/opt/puppetlabs/puppet/etc/gemrc']:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('classroom/gemrc.epp', { offline => $offline }),
    }
  }

  # This is a bit dirty...
  File <| tag == 'classroom::gemrc' |> -> Package<| provider == 'gem' |>
  File <| tag == 'classroom::gemrc' |> -> Package<| provider == 'puppet_gem' |>
  File <| tag == 'classroom::gemrc' |> -> Package<| provider == 'puppetserver_gem' |>
}

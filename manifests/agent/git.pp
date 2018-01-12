class classroom::agent::git {
  assert_private('This class should not be called directly')

  case $::osfamily {
    'windows' : {
      $environment = undef
      $path        = 'C:/Program Files/Git/bin'
      $sshpath     = 'C:/Program Files/Git/.ssh'
      $permissions = undef
    }
    default   : {
      $environment = 'HOME=/root'
      $path        = '/usr/bin:/bin:/user/sbin:/usr/sbin'
      $sshpath     = '/root/.ssh'
      $permissions = '0600'
    }
  }
  Exec {
    environment => $environment,
    path        => $path,
  }

  if $::osfamily == 'windows'{
    require classroom::windows

    package { ['git', 'kdiff3']:
      ensure   => present,
      provider => 'chocolatey',
      before   => [ File[$sshpath], Exec['generate_key'] ],
    }

    # TODO: the source param fails spec testing
    #       Failed to convert 'C:/Program Files/Git/.ssh' to URI: bad component(expected absolute path component)
    file { 'C:/Users/Administrator/.ssh/':
      ensure  => directory,
      source  => $sshpath,
      recurse => true,
      require => [ File[$sshpath], Exec['generate_key'] ],
    }

    windows_env { 'PATH=C:\Program Files\Git\bin': }
  }
  else {
    class { '::git':
      before => [ File[$sshpath], Exec['generate_key'] ],
    }
  }
    
  file { $sshpath:
    ensure => directory,
    mode   => $permissions,
  }    

  exec { 'generate_key':
    command => $::osfamily ? {
      'windows' => "bash.exe -c \"ssh-keygen -t rsa -N '' -f '${sshpath}/id_rsa'\"",
      'RedHat'  => "ssh-keygen -t rsa -N '' -f '${sshpath}/id_rsa'",
      # no default should make catalog compilation fail on other OS families
    },
    creates => "${sshpath}/id_rsa",
    require => File[$sshpath],
  }

  exec { "git config --global user.name '${classroom::params::machine_name}'":
    unless  => 'git config --global user.name',
    require => Exec['generate_key'],
  }

  exec { "git config --global user.email ${classroom::params::machine_name}@puppetlabs.vm":
    unless  => 'git config --global user.email',
    require => Exec['generate_key'],
  }

  exec { 'git config --global color.ui always':
    unless  => 'git config --global color.ui',
    require => Exec['generate_key'],
  }

}

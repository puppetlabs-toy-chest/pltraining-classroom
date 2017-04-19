class classroom::agent::augeas {
  if $facts['augeas']['version'] == '1.4.0' {
    # The version of Augeas that ships with PE doesn't support current krb5.conf
    # until it's updated, install a new lens.
    $lens_dirs = [
      '/opt/puppetlabs/puppet/share/augeas/lenses/dist',
      '/usr/share/augeas/lenses/dist',
    ]

    $lens_dirs.each |$lens_dir| {
      file { $lens_dir:
        ensure => directory,
      }
      file { "${lens_dir}/krb5.aug":
        ensure => file,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/classroom/krb5.aug',
      }
    }
  }

  # Also install a krb5.conf file that works with the Augeas lab
  # in the Practitioner course
  file { '/etc/krb5.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/classroom/krb5.conf',
  }
}

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
}

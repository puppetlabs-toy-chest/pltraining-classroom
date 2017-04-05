class classroom::augeas {
  if $facts['augeas']['version'] == '1.4.0' {
    # The version of Augeas that ships with PE doesn't support current krb5.conf
    # until it's updated, install a new lens.
    $lenses = [
      '/opt/puppetlabs/puppet/share/augeas/lenses/dist/krb5.aug',
      '/usr/share/augeas/lenses/dist/krb5.aug',
    ]
    
    file { $lenses:
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/classroom/krb5.aug',
    }
  }
  
}

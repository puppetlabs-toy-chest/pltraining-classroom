# Create link for the cached wordpress tarball
class classroom::master::lab_files {
  file { '/opt/puppetlabs/server/data/packages/public/wordpress-3.8.tar.gz':
    ensure => link,
    target => '/usr/src/wordpress/wordpress-3.8.tar.gz',
  }
}

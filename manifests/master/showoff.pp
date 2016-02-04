class classroom::master::showoff (
  Optional[String] $password,
  String $courseware_source = $classroom::params::courseware_source,
) inherits classroom::params {
  include stunnel
  require showoff
  require classroom::master::pdf_stack

  # We use this resource so that any time an instructor uploads new content,
  # the PDF files will be rebuilt via the dependent exec statement
  # This source path will be created via a courseware rake task.
  file { "${showoff::root}/courseware":
    ensure  => directory,
    owner   => $showoff::user,
    mode    => '0644',
    recurse => true,
    source  => $courseware_source,
    notify  => Exec['build_pdfs'],
  }

  exec { 'build_pdfs':
    command     => "rake watermark target=_files/share password=${password}",
    cwd         => "${showoff::root}/courseware/",
    path        => '/bin:/usr/bin:/usr/local/bin',
    environment => ['HOME=/root'],
    refreshonly => true,
  }

  showoff::presentation { 'courseware':
    path      => "${showoff::root}/courseware/",
    subscribe => File["${showoff::root}/courseware"],
  }

  file { '/etc/stunnel/showoff.pem':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    source => 'puppet:///modules/classroom/showoff.pem',
    before => Stunnel::Tun['showoff-ssl'],
  }

  stunnel::tun { 'showoff-ssl':
    accept  => '9091',
    connect => 'localhost:9090',
    options => 'NO_SSLv2',
    cert    => '/etc/stunnel/showoff.pem',
    client  => false,
  }

  if $classroom::manage_selinux {
    # Source code in stunnel-showoff.te
    file { '/usr/share/selinux/targeted/stunnel-showoff.pp':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/classroom/selinux/stunnel-showoff.pp',
    }

    selmodule { 'stunnel-showoff':
      ensure => present,
    }
  }

}

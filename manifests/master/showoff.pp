class classroom::master::showoff (
  String $training_user = $classroom::params::training_user,
) inherits classroom::params {
  include stunnel
  require classroom::master::dependencies::rubygems
  require showoff
  require classroom::master::pdf_stack

  # where the source files are uploaded by the instructor's tooling
  $courseware_source = "/home/${training_user}/courseware"

  # We use this resource so that any time an instructor uploads new content,
  # the PDF files will be rebuilt via the dependent exec statement
  # This source path will be created via a courseware rake task.
  file { "${showoff::root}/courseware":
    ensure  => directory,
    owner   => $showoff::user,
    mode    => '0644',
    recurse => remote,
    source  => $courseware_source,
    notify  => Exec['build_pdfs'],
    require => File[$courseware_source],
  }

  # Create the courseware_source dir so the first puppet run doesn't error.
  # The rake task will upload content to this dir for the presentation.
  file { $courseware_source:
    ensure => directory,
    owner   => $training_user,
    mode    => '0644',
  }

  exec { 'build_pdfs':
    command     => "rake watermark target=_files/share",
    cwd         => "${showoff::root}/courseware/",
    path        => '/bin:/usr/bin:/usr/local/bin',
    user        => $showoff::user,
    environment => ['HOME=/tmp'],
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
    connect => '127.0.0.1:9090',
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

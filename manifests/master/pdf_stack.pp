# Dependencies for PDF rendering
#
# NOTE: This class is deprecated, since the bootstrap manages these resources already.
#       Remove this along with classroom::master::showoff::legacy
#
class classroom::master::pdf_stack {

  if(defined('$classroom::offline') and $classroom::offline) {
    $enabled = '0'
  }
  else {
    $enabled = '1'
  }

  yumrepo { 'robert-gcj':
    ensure              => 'present',
    baseurl             => 'https://copr-be.cloud.fedoraproject.org/results/robert/gcj/epel-7-$basearch/',
    descr               => 'Copr repo for gcj owned by robert',
    enabled             => $enabled,
    gpgcheck            => '1',
    gpgkey              => 'https://copr-be.cloud.fedoraproject.org/results/robert/gcj/pubkey.gpg',
    skip_if_unavailable => true,
  }

  yumrepo { 'robert-pdftk':
    ensure              => 'present',
    baseurl             => 'https://copr-be.cloud.fedoraproject.org/results/robert/pdftk/epel-7-$basearch/',
    descr               => 'Copr repo for pdftk owned by robert',
    enabled             => $enabled,
    gpgcheck            => '1',
    gpgkey              => 'https://copr-be.cloud.fedoraproject.org/results/robert/pdftk/pubkey.gpg',
    skip_if_unavailable => true,
    require             => Yumrepo['robert-gcj'],
  }

  package { ['wkhtmltopdf', 'pdftk']:
    ensure  => present,
    require => Yumrepo['robert-pdftk'],
  }

  package { 'puppet-courseware-manager':
    ensure   => present,
    provider => gem,
  }

  $fonts = [
    'ucs-miscfixed-fonts.noarch',
    'xorg-x11-fonts-75dpi.noarch',
    'xorg-x11-fonts-Type1.noarch',
    'open-sans-fonts.noarch',
  ]

  package { $fonts:
    ensure => present,
  }

  # TODO: merge this with ^^ in a couple releases
  if $::classroom_vm_release and versioncmp($::classroom_vm_release, '7.0') >= 0 {
    package { 'google-droid-sans-mono': # cached locally by the bootstrap module
      ensure => present,
    }
  }
}

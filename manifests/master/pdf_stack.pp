# Dependencies for PDF rendering
class classroom::master::pdf_stack {

  $enabled = $classroom::offline ? {
    true  => '0',
    false => '1',
    undef => '1',   # TODO: this is a terrible temporary hack
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

  # Regression in 0.12.4, https://github.com/wkhtmltopdf/wkhtmltopdf/issues/3241
  package { 'wkhtmltopdf':
    ensure  => '0.12.3-1',
    require => Yumrepo['robert-pdftk'],
  }

  package { 'pdftk':
    ensure  => present,
    require => Yumrepo['robert-pdftk'],
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

}

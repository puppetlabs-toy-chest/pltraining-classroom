class classroom::windows::geotrust {
  assert_private('This class should not be called directly')

  exec { 'download-geotrust-cert':
    command  => 'Invoke-Webrequest https://www.geotrust.com/resources/root_certificates/certificates/GeoTrust_Global_CA.pem -outfile c:\windows\temp\GeoTrust_Glocal_CA.pem',
    creates  => 'c:/windows/temp/GeoTrust_Glocal_CA.pem',
    provider => powershell,
    timeout  => $classroom::timeout,
  }
  exec { 'install-geotrust-cert':
    command  => 'certutil -addstore root c:\windows\temp\GeoTrust_Glocal_CA.pem',
    provider => powershell,
    refreshonly => true,
    subscribe  => Exec['download-geotrust-cert'],
  }
}

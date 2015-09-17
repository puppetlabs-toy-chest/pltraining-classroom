class classroom::windows::geotrust {
  assert_private('This class should not be called directly')

  exec { 'download-geotrust-cert':
    command  => '$wc = New-Object System.Net.WebClient;$wc.DownloadFile("https://www.geotrust.com/resources/root_certificates/certificates/GeoTrust_Global_CA.pem","C:\Windows\Temp\GeoTrust_Glocal_CA.pem")',
    creates  => 'C:/Windows/Temp/GeoTrust_Glocal_CA.pem',
    provider => powershell,
    timeout  => $classroom::timeout,
  }
  exec { 'install-geotrust-cert':
    command     => 'certutil -addstore root C:\Windows\Temp\GeoTrust_Glocal_CA.pem',
    provider    => powershell,
    refreshonly => true,
    subscribe   => Exec['download-geotrust-cert'],
  }
}

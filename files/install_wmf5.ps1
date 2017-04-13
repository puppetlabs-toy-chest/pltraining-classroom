#This script is only tested against and should only run on 2012R2 systems.
#There are caveats and issues upgrading from WMF 3 to 5 on 2008R2/Win7 that
#this script does not consider due to classroom environment being 2012R2.

#Modifiable variables are below. Update these as needed to match the WMF
#you want to have installed. Only update the DownloadUrl if Microsoft changes path.
$wmfInstallerFile = 'Win8.1AndW2K12R2-KB3134758-x64.msu'
$wmfDownloadUrl = "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/$wmfInstallerFile"

$wmfPath = 'c:\temp'
$wmfInstaller = Join-Path $wmfPath $wmfInstallerFile

Write-Output 'Setting up DSC components'

# Running this command may not be necessary, but breaks nothing, presumably.
cmd /c "sc config wuauserv start= demand"

if (!(Test-Path $wmfPath)) {
  Write-Output "Creating folder `'$wmfPath`'"
    $null = New-Item -Path "$wmfPath" -ItemType Directory
}

if (!(Test-Path $wmfInstaller)) {
  Write-Output "Downloading `'$wmfDownloadUrl`' to `'$wmfInstaller`'"
    (New-Object Net.WebClient).DownloadFile("$wmfDownloadUrl","$wmfInstaller")
}
Write-Output "Installing WMF 5.0"
& $wmfInstaller /quiet /norestart

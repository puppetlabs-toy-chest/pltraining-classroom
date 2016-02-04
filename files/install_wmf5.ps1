WriteOutput 'Setting up DSC components'

$wmfPath = 'c:\temp'
$systemModules = "$env:ProgramFiles\WindowsPowerShell\Modules"

# Would you believe the space after the equals is required?!
cmd /c "sc config wuauserv start= demand"

# August 2015 Production Preview
$wmfDownloadUrl = 'https://download.microsoft.com/download/3/F/D/3FD04B49-26F9-4D9A-8C34-4533B9D5B020/Win8.1AndW2K12R2-KB3066437-x64.msu'
$wmfInstallerFile = 'Win8.1AndW2K12R2-KB3066437-x64.msu'

$wmfInstaller = Join-Path $wmfPath $wmfInstallerFile

if (!(Test-Path $wmfPath)) {
  Write-Output "Creating folder `'$wmfPath`'"
    $null = New-Item -Path "$wmfPath" -ItemType Directory
}

if (!(Test-Path $wmfInstaller)) {
  Write-Output "Downloading `'$wmfDownloadUrl`' to `'$wmfInstaller`'"
    (New-Object Net.WebClient).DownloadFile("$wmfDownloadUrl","$wmfInstaller")
}

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.WorkingDirectory = "$wmfPath"
$psi.FileName = "$wmfInstallerFile"
$psi.Arguments = "/quiet" # /norestart /log `'$wmfPath\wmfInstall.log`'"
#$psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Minimized;

Write-Output "Installing `'$wmfInstaller`'"
$s = [System.Diagnostics.Process]::Start($psi);

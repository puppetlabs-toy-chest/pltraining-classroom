##############################
### Check if Administrator ###
##############################
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

#############################
### Set the computer name ###
#############################
$computerName = Read-Host -Prompt 'Input desired user name: '
Rename-Computer $ComputerName

#########################
### Set the FQDN name ###
#########################
$DNSSuffix = "puppetlabs.vm"
$oldDNSSuffix = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name "NV Domain")."NV Domain"

Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name Domain -Value $DNSSuffix
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name "NV Domain" -Value $DNSSuffix

#################################
### Set host entry for master ###
#################################
Start-Sleep -s 3
$master_ip = Read-Host -Prompt 'Input the IP Address of the Master'
Write-Host "`n`nAdding entry to the hosts file`n`n"
ac -Encoding UTF8 C:\Windows\system32\drivers\etc\hosts "$master_ip master.$DNSSuffix master"

###########################################
### Set password complexity requirement ###
###########################################
Start-Sleep -s 3
Write-Host "`n`nSetting Local Security Settings`n`n"
secedit /export /cfg c:\secpol.cfg
(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
rm -force c:\secpol.cfg -confirm:$false

####################################
### Download setup_classroom.ps1 ###
####################################
[System.Net.ServicePointManager]::ServerCertificateValidationCallback={$true}
$url = "https://$master_ip:8140/packages/current/windows-x86_64/setup_classroom.ps1"
$output = "C:\Users\Administrator\setup_classroom.ps1"
(New-Object System.Net.WebClient).DownloadFile($url, $output)

#############################
### Download puppet agent ###
#############################
$url = "https://$master_ip:8140/packages/current/windows-x86_64/puppet-agent-x64.msi"
$output = "C:\Users\Administrator\Downloads\puppet-agent-x64.msi"
(New-Object System.Net.WebClient).DownloadFile($url, $output)

############################
### Restart the computer ###
############################
Start-Sleep -s 5
Write-Host "`n`n`nRebooting in 5 seconds`n`n`n"
Restart-Computer

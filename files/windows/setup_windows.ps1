##############################
### Check if Administrator ###
##############################
$user = [Environment]::UserName
If ($user -ne "Administrator") {
      Write-Host "`n`n`nPlease logout and login as Administrator!`n`n`n"
      Start-Sleep -s 5
      break
} else {
      Write-Host "`n`n`nContinuing the setup.`n`n`n"
}

#############################
### Set the computer name ###
#############################
$computerName = Read-Host -Prompt 'Input desired user name: '
Rename-Computer $ComputerName.ToLower()

#########################
### Set the FQDN name ###
#########################
$DNSSuffix = "puppetlabs.vm"

Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name Domain -Value $DNSSuffix
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name "NV Domain" -Value $DNSSuffix

#################################
### Set host entry for master ###
#################################
Start-Sleep -s 3
$master_ip = Read-Host -Prompt 'Input the IP Address of the Master'
Write-Host "`n`nAdding entry to the hosts file`n`n"
ac -Encoding UTF8 C:\Windows\system32\drivers\etc\hosts "$master_ip master.$DNSSuffix master"

################################
### Setup PowerShell Profile ###
################################
New-Item -ItemType directory -Path c:\puppetcode
New-Item -path $profile -type file -force
Write-Host "`n`nAdding PowerShell Profile`n`n"
ac -Encoding UTF8 C:\Users\Administrator\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 "set-location c:\puppetcode"

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
$url = "https://master.puppetlabs.vm:8140/packages/current/windows-x86_64/setup_classroom.ps1"
$output = "C:\Users\Administrator\setup_classroom.ps1"
(New-Object System.Net.WebClient).DownloadFile($url, $output)

#############################
### Download puppet agent ###
#############################
$url = "https://master.puppetlabs.vm:8140/packages/current/windows-x86_64/puppet-agent-x64.msi"
$output = "C:\Users\Administrator\Downloads\puppet-agent-x64.msi"
(New-Object System.Net.WebClient).DownloadFile($url, $output)

##########################
### Set RunOnce Script ###
##########################
New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce -Value "Powershell C:\Users\Administrator\setup_classroom.ps1"

############################
### Restart the computer ###
############################
$confirmation = Read-Host "`n`n`nRebooting in 5 seconds, continue? y/n`n`n`n"
If ($confirmation -eq 'y') {
    Start-Sleep -s 5
    Restart-Computer
} else {
    Write-Host "`n`n`nYou will have to reboot manually to continue with the setup!`n`n`n"
    break
}

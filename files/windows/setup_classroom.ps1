#######################
### determine agent ###
#######################
$dir = "C:\Users\Administrator\Downloads"
$agent = Get-ChildItem $dir | Where-Object {$_.Extension -eq ".msi"}
msiexec /qn /norestart /l*v puppet_agent_install.log /i $agent.fullname PUPPET_MASTER_SERVER=master.puppetlabs.vm

#############################
### Remove RunOnce Script ###
#############################
Remove-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce

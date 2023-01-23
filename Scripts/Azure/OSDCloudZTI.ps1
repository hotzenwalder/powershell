Write-Host  -ForegroundColor Cyan "Starten OSDCloud FNV..."
Write-Host  -ForegroundColor Cyan "Meer informatie: Marcel Moerings"
Start-Sleep -Seconds 5

#Make sure I have the latest OSD Content
#Write-Host  -ForegroundColor Cyan "Updaten OSD PowerShell Module"
Install-Module OSD -Force

Write-Host  -ForegroundColor Cyan "Importeren OSD PowerShell Module"
Import-Module OSD -Force

#Start OSDCloud ZTI the RIGHT way
Write-Host  -ForegroundColor Cyan "Starten OSDCloud met FNV instellingen"
Start-OSDCloud -OSVersion 'Windows 10' -OSBuild 22H2 -OSEdition Enterprise -OSLanguage nl-nl -ZTI

#Restart from WinPE
Write-Host  -ForegroundColor Cyan "Herstarten in 20 seconden..."
Start-Sleep -Seconds 20
wpeutil reboot
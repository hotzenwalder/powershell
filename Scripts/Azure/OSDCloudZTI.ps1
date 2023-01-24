Write-Host -ForegroundColor Cyan "Starten OSDCloud FNV"
Write-Host -ForegroundColor Cyan "Meer informatie: Marcel Moerings"
Write-Host ""
Start-Sleep -Seconds 3

#Make sure I have the latest OSD Content
#Write-Host  -ForegroundColor Cyan "Updaten OSD PowerShell Module"
#Install-Module OSD -Force

Write-Host  -ForegroundColor Cyan "Importeren OSD PowerShell Module"
Import-Module OSD -Force

Write-Host -ForegroundColor Cyan "Dit script wist de harde schijf en installeert een schone Windows 10 22H2"
Write-Host -ForegroundColor Cyan "Alle gegevens gaan verloren!"
Write-Host ""
Write-Host  -ForegroundColor Red "Weet je zeker dat je het systeem wilt wissen en herinstalleren?"

$Selection=""
While($Selection -ne "J" ){
   $Selection = read-host "Doorgaan? (J/N)"
    Switch ($Selection) 
        { 
            Y {Write-host -ForegroundColor Red "Doorgaan met wissen"} 
            N {Write-Host -ForegroundColor Red "Stoppen met uitvoer";Return} 
            default {Write-Host "Alleen J/N is een geldig antwoord"}
        } 
}

#Start OSDCloud ZTI the RIGHT way
Write-Host  -ForegroundColor Cyan "Starten OSDCloud met FNV instellingen"
Start-OSDCloud -OSVersion 'Windows 10' -OSBuild 22H2 -OSEdition Enterprise -OSLanguage nl-nl -ZTI

#Restart from WinPE
Write-Host  -ForegroundColor Cyan "Herstarten in 20 seconden..."
Start-Sleep -Seconds 20
wpeutil reboot

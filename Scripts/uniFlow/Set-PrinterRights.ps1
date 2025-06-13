# STEP: Allow Printer Installation for Non-Admins and Set Device Class Permissions
Write-Host "Configuring system for non-admin printer installation..."

function Ensure-RegistryPath {
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

function Set-RegistryValue {
    param (
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [object]$Value,
        [Parameter(Mandatory)]
        [Microsoft.Win32.RegistryValueKind]$Type
    )
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force -ErrorAction SilentlyContinue | Out-Null
}

# Step 1: Allow printer driver install without admin
$driverPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PackagePointAndPrint"
)

foreach ($path in $driverPaths) {
    Ensure-RegistryPath -Path $path
    Set-RegistryValue -Path $path -Name "RestrictDriverInstallationToAdministrators" -Value 0 -Type DWord
}

# Step 2: Set allowed device classes for printer devices
$deviceClassPath = "HKLM:\Software\Policies\Microsoft\Windows\DriverInstall\Restrictions\AllowUserDeviceClasses"
$restrictionPath = "HKLM:\Software\Policies\Microsoft\Windows\DriverInstall\Restrictions"

Ensure-RegistryPath -Path $deviceClassPath
Ensure-RegistryPath -Path $restrictionPath

# Set device class GUIDs
Set-RegistryValue -Path $deviceClassPath -Name "printer"     -Value "{4658ee7e-f050-11d1-b6bd-00c04fa372a7}" -Type String
Set-RegistryValue -Path $deviceClassPath -Name "PNPprinter"  -Value "{4d36e979-e325-11ce-bfc1-08002be10318}" -Type String
Set-RegistryValue -Path $restrictionPath -Name "AllowUserDeviceClasses" -Value 1 -Type DWord

Write-Host "Registry settings applied successfully."

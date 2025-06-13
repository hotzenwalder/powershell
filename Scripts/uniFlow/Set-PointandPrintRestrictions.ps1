# Set Point and Print Restrictions
# RUN with Admin or SYSTEM rights
Write-Host "Configuring Point and Print restrictions..." -ForegroundColor Cyan

# --- Define trusted print servers ---
$printServers = @(
    "PRN01.CONTOSO.COM",
    "PRN02.CONTOSO.COM",
    "PRN03.CONTOSO.COM"
)

# --- Helper function to ensure registry path and set value ---
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

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    # Use Set-ItemProperty to safely overwrite or create the property
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction SilentlyContinue
}

# --- Static values for PointAndPrint restrictions ---
$registryItems = @(
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PackagePointAndPrint"; Name = "PackagePointAndPrintServerList"; Value = 1; Type = [Microsoft.Win32.RegistryValueKind]::DWord },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"; Name = "Restricted"; Value = 1; Type = [Microsoft.Win32.RegistryValueKind]::DWord },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"; Name = "TrustedServers"; Value = 1; Type = [Microsoft.Win32.RegistryValueKind]::DWord },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"; Name = "InForest"; Value = 0; Type = [Microsoft.Win32.RegistryValueKind]::DWord },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"; Name = "NoWarningNoElevationOnInstall"; Value = 1; Type = [Microsoft.Win32.RegistryValueKind]::DWord },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"; Name = "UpdatePromptSettings"; Value = 2; Type = [Microsoft.Win32.RegistryValueKind]::DWord },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"; Name = "ServerList"; Value = ($printServers -join ";"); Type = [Microsoft.Win32.RegistryValueKind]::String }
)

# --- Per-server entries under ListofServers ---
foreach ($server in $printServers) {
    $registryItems += @{
        Path  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PackagePointAndPrint\ListofServers"
        Name  = $server
        Value = $server
        Type  = [Microsoft.Win32.RegistryValueKind]::String
    }
}

# --- Apply registry changes ---
foreach ($item in $registryItems) {
    try {
        Set-RegistryValue -Path $item.Path -Name $item.Name -Value $item.Value -Type $item.Type
        Write-Host "Set $($item.Name) in $($item.Path)" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to set $($item.Name) in $($item.Path): $_"
    }
}

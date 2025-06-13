# Add Canon UniFlow Printers from on-premises printservers
# Run this script in the USER context, so not with Admin or SYSTEM rights
# Define your printerservers in the $printers array

# Function to install a single printer
function Set-LocalPrinter {
    param (
        [Parameter(Mandatory=$true)][string]$Server,
        [Parameter(Mandatory=$true)][string]$PrinterName
    )

    $printerPath = "\\$Server\$PrinterName"

    if (Get-Printer -Name $printerPath -ErrorAction SilentlyContinue) {
        Write-Log "Printer $printerPath already installed"
    } else {
        Write-Log "Installing printer $printerPath"
        try {
            & cscript /nologo "$env:SystemRoot\System32\Printing_Admin_Scripts\nl-NL\prnmngr.vbs" -ac -p $printerPath
            if (Get-Printer -Name $printerPath -ErrorAction SilentlyContinue) {
                Write-Log "$printerPath successfully installed"
            } else {
                Write-Log "$printerPath not successfully installed"
                Write-Warning "$printerPath not successfully installed"
            }
        } catch {
            Write-Warning "Error installing printer $printerPath : $_"
            Write-Log "Error installing printer $printerPath : $_"
        }
    }
}

# List of printers to install
$printers = @(
    "PRN01.CONTOSO.COM",
    "PRN02.CONTOSO.COM",
    "PRN03.CONTOSO.COM"
) | ForEach-Object {
    [PSCustomObject]@{ Printer = "FollowMe-CONTOSO"; Server = $_ }
}

# Check for existing FollowMe printers
$installedPrinters = Get-Printer | Where-Object { $_.Name -like '*FollowMe*' }

if ($installedPrinters.Count -lt $printers.Count) {
    Write-Log "Some printers are missing. Installing required printers..."
    foreach ($p in $printers) {
        Set-LocalPrinter -Server $p.Server -PrinterName $p.Printer
    }
} else {
    Write-Log "All required printers are already installed."
}

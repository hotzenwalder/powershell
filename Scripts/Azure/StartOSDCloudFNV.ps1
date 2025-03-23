N# Import necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to create a styled custom message box
function Show-CustomMessageBox {
    param (
        [string]$Message,
        [string]$Title
    )

    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size(400, 200)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::White

    # Add a label to display the message
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Message
    $label.AutoSize = $true
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $label.Location = New-Object System.Drawing.Point(20, 30)
    $form.Controls.Add($label)

    # Add an OK button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object System.Drawing.Point(150, 100)
    $okButton.BackColor = [System.Drawing.Color]::LightGray
    $okButton.FlatStyle = "Flat"
    $okButton.Add_Click({
        $form.Close()
    })
    $form.Controls.Add($okButton)

    # Show the form as a dialog
    $form.ShowDialog() | Out-Null
}

# Function to create a dropdown form for domain selection
function Show-DomainSelectionForm {
    param (
        [string[]]$Options
    )

    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Selecteer het OS voor dit systeem"
    $form.Size = New-Object System.Drawing.Size(400, 200)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::White

    # Add a label
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Selecteer het OS:"
    $label.AutoSize = $true
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $form.Controls.Add($label)

    # Add the dropdown box
    $dropdown = New-Object System.Windows.Forms.ComboBox
    $dropdown.Location = New-Object System.Drawing.Point(20, 50)
    $dropdown.Size = New-Object System.Drawing.Size(340, 20)
    $dropdown.DropDownStyle = "DropDownList"
    $dropdown.Items.AddRange($Options)
    $form.Controls.Add($dropdown)

    # Add an OK button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object System.Drawing.Point(140, 100)
    $okButton.BackColor = [System.Drawing.Color]::LightGray
    $okButton.FlatStyle = "Flat"
    $okButton.Add_Click({
        if ($dropdown.SelectedItem) {
            $form.Tag = $dropdown.SelectedItem
            $form.Close()
        } else {
            Show-CustomMessageBox -Message "Selecteer een OS voor je verder gaat." -Title "Validation Error"
        }
    })
    $form.Controls.Add($okButton)

    # Show the form as a dialog
    $form.ShowDialog() | Out-Null
    return $form.Tag
}

# Domain options
$OSDOptions = @("Windows 11 24H2", "Windows 10 22H2")

# Show domain selection form
$selectedOSD = Show-DomainSelectionForm -Options $OSDOptions

# Validate selection
if (-not $selectedOSD) {
    Show-CustomMessageBox -Message "Geen OS geselecteerd. Script gestopt." -Title "Error"
    exit
}

# Function to show a confirmation message box
function Show-ConfirmationBox {
    param (
        [string]$Message,
        [string]$Title
    )

    $result = [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)

    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        return "J"
    } else {
        return "N"
    }
}

# Show confirmation message box
$Selection = Show-ConfirmationBox -Message "Weet je zeker dat je het systeem wilt wissen en herinstalleren met $SelectedOSD?" -Title "Bevestiging"

if ($Selection -eq "J") {
    Write-Host "Starten OSDCloud ($selectedOSD)"
} else {
    Write-Host "Stoppen met uitvoer script"
    exit
}

#Start OSDCloud ZTI the RIGHT way
If ($selectedOSD -eq "Windows 11 24H2"){
    Write-Host  "Starten OSDCloud ($SelectedOSD)"
    iex (irm osdcloud.coloneldecker.com)
}

If ($selectedOSD -eq "Windows 10 22H2"){
    Write-Host "Starten OSDCloud ($SelectedOSD)"
    iex (irm windows10.coloneldecker.com)
}

#Restart from WinPE
Write-Host  -ForegroundColor Cyan "Herstarten in 20 seconden..."
Start-Sleep -Seconds 20
wpeutil reboot

# Import necessary assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to create a dropdown form for OS selection
function Show-DomainSelectionForm {
    param (
        [string[]]$Options
    )

    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Selecteer het OS"
    $form.Size = New-Object System.Drawing.Size(450, 220)  # Increased width and height
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::White

    # Add a label
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Selecteer het OS:"
    $label.Size = New-Object System.Drawing.Size(400, 40)  # Adjusted width, allows wrapping
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $label.AutoSize = $false  # Prevents text from getting cut off
    $form.Controls.Add($label)

    # Add the dropdown box
    $dropdown = New-Object System.Windows.Forms.ComboBox
    $dropdown.Location = New-Object System.Drawing.Point(20, 70)
    $dropdown.Size = New-Object System.Drawing.Size(400, 20)  # Adjusted width
    $dropdown.DropDownStyle = "DropDownList"
    $dropdown.Items.AddRange($Options)
    $form.Controls.Add($dropdown)

    # Add an OK button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object System.Drawing.Point(175, 130)  # Centered button
    $okButton.Size = New-Object System.Drawing.Size(100, 30)  # Bigger button for better UI
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
    Show-CustomMessageBox -Message "No domain selected. Exiting script." -Title "Error"
    exit
}

# Function to show a custom confirmation message box with a resizable form
function Show-ConfirmationBox {
    param (
        [string]$Message,
        [string]$Title
    )

    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size(450, 200)  # Increased width and height
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::White
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false

    # Add a label to display the message
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Message
    $label.Size = New-Object System.Drawing.Size(400, 60)  # Adjusted width for better text wrapping
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $label.Location = New-Object System.Drawing.Point(25, 20)
    $label.TextAlign = "MiddleCenter"
    $form.Controls.Add($label)

    # Add "Yes" button (J)
    $yesButton = New-Object System.Windows.Forms.Button
    $yesButton.Text = "Ja (J)"
    $yesButton.Location = New-Object System.Drawing.Point(100, 100)
    $yesButton.Size = New-Object System.Drawing.Size(100, 30)
    $yesButton.BackColor = [System.Drawing.Color]::LightGray
    $yesButton.FlatStyle = "Flat"
    $yesButton.Add_Click({
        $form.Tag = "J"
        $form.Close()
    })
    $form.Controls.Add($yesButton)

    # Add "No" button (N)
    $noButton = New-Object System.Windows.Forms.Button
    $noButton.Text = "Nee (N)"
    $noButton.Location = New-Object System.Drawing.Point(250, 100)
    $noButton.Size = New-Object System.Drawing.Size(100, 30)
    $noButton.BackColor = [System.Drawing.Color]::LightGray
    $noButton.FlatStyle = "Flat"
    $noButton.Add_Click({
        $form.Tag = "N"
        $form.Close()
    })
    $form.Controls.Add($noButton)

    # Show the form as a dialog
    $form.ShowDialog() | Out-Null
    return $form.Tag
}

# Show confirmation message box
$Selection = Show-ConfirmationBox -Message "Weet je zeker dat je het systeem wilt wissen en herinstalleren?" -Title "Bevestiging"

if ($Selection -eq "J") {
    #Start OSDCloud ZTI the RIGHT way
    If ($selectedOSD -eq "Windows 11 24H2"){
        Write-Host  "Starten OSDCloud ($SelectedOSD)"
        Try{
            iex (irm osdcloud.coloneldecker.com)
        } Catch {
            Write-Host "Er ging iets fout met OSDCloud" -ForegroundColor Red
            Sleep 5
            exit
        }        
    }

    If ($selectedOSD -eq "Windows 10 22H2"){
        Write-Host "Starten OSDCloud ($SelectedOSD)"
        Try {
            iex (irm windows10.coloneldecker.com)
        } Catch {
            Write-Host "Er ging iets fout met OSDCloud" -ForegroundColor Red
            Sleep 5
            exit
        }
    }
} else {
    Write-Host "Script gestopt. Systeem wordt niet opnieuw geinstalleerd" -ForegroundColor Yellow
    exit
}

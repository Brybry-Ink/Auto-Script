This file should be in .ps1 for it to work
Example: Autoinstallscript.ps1
# Main Script: Application Selection and Generation of an Execution Script

# --- OS Selection ---
do {
    Clear-Host
    Write-Host "Select your Operating System:" -ForegroundColor Cyan
    Write-Host "1. Windows"
    Write-Host "2. Linux"
    $userOSInput = Read-Host "Enter 1 or 2"

    switch ($userOSInput) {
        "1" {
            $osSelection = "Windows"
            $validOS = $true
        }
        "2" {
            Write-Host "Linux support is not finished yet. Please select a different option." -ForegroundColor Red
            Start-Sleep 2
            $validOS = $false
        }
        Default {
            Write-Host "Invalid selection. Please try again." -ForegroundColor Red
            Start-Sleep 2
            $validOS = $false
        }
    }
} until ($validOS)

# --- Application Selection ---
# Define the available applications.
$options = @(
    "Steam",
    "Adobe Reader",
    "Microsoft Teams",
    "FireFox",
    "Discord",
    "Google Chrome",
    "Notepad ++"
)

$selectedOptions = @()

while ($true) {
    Clear-Host

    # Display Available Options with Numbers
    Write-Host "Available Options:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $options.Count; $i++) {
        Write-Host ("{0}. {1}" -f ($i + 1), $options[$i])
    }
    
    # Display Selected Options
    Write-Host "`nSelected Options:" -ForegroundColor Green
    if ($selectedOptions.Count -eq 0) {
        Write-Host "None"
    } else {
        $selectedOptions | ForEach-Object { Write-Host $_ }
    }
    
    Write-Host "`nEnter the number of an option to add/remove it, or 'X' to finish:" -ForegroundColor Yellow
    $userInput = Read-Host "Your Selection"
    
    if ($userInput -match '^[Xx]$') {
        break
    }
    
    if ([int]::TryParse($userInput, [ref]$null)) {
        $choiceNumber = [int]$userInput
        if ($choiceNumber -ge 1 -and $choiceNumber -le $options.Count) {
            $optionName = $options[$choiceNumber - 1]
            if ($selectedOptions -contains $optionName) {
                $removeChoice = Read-Host "`n$optionName is already selected. Do you want to remove it? (Y/N)"
                if ($removeChoice -match '^[Yy]$') {
                    $selectedOptions = $selectedOptions | Where-Object { $_ -ne $optionName }
                    Write-Host "$optionName removed." -ForegroundColor Red
                }
            } else {
                $selectedOptions += $optionName
                Write-Host "$optionName added." -ForegroundColor Green
            }
        } else {
            Write-Host "Invalid number. Please select a number between 1 and $($options.Count)." -ForegroundColor Red
        }
    }
    else {
        Write-Host "Invalid input. Please enter a valid number or 'X' to finish." -ForegroundColor Red
    }
    
    Start-Sleep 1.5
}

if ($selectedOptions.Count -eq 0) {
    Write-Host "No applications selected. Exiting..." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# --- Generate Execution Script ---
#Hard coded File path for application exe.
$exeFolder = "C:\Users\antho\Temp\Application .EXE"

# The generated script will be placed in the Temp folder. This should be changed to the desktop later on or download
$tempPath = "C:\Users\antho\Temp"
if (!(Test-Path $tempPath)) {
    New-Item -ItemType Directory -Path $tempPath | Out-Null
}

$generatedScriptPath = "$tempPath\open_selected_apps.ps1"

# Begin building the generated script content.
$scriptContent = @"
# Generated Execution Script
# This script opens the installer (EXE) files from a hardcoded folder.
`$exeFolder = "$exeFolder"

"@

#  applications with their correct filenames.
$appFileMap = @{
    "Steam"            = "SteamSetup.exe"
    "Adobe Reader"     = "Reader_en_install.exe"
    "Microsoft Teams"  = "MSTeamsSetup.exe"
    "FireFox"          = "Firefox Installer.exe"
    "Discord"          = "DiscordSetup.exe"
    "Google Chrome"    = "ChromeSetup.exe"
    "Notepad ++"       = "npp.8.7.6.Installer.x64.exe"
}

# For each selected application, add a command that opens the corresponding EXE.
foreach ($app in $selectedOptions) {
    if ($appFileMap.ContainsKey($app)) {
        $exeFile = $appFileMap[$app]
        $scriptContent += "if (Test-Path `"$exeFolder\$exeFile`") {`n"
        $scriptContent += "    Start-Process `"$exeFolder\$exeFile`"`n"
        $scriptContent += "} else {`n"
        $scriptContent += "    Write-Host `"Error: $app installer not found at $exeFolder\$exeFile`" -ForegroundColor Red`n"
        $scriptContent += "}`n`n"
    }
}

# Write the generated script to file.
$scriptContent | Out-File -FilePath $generatedScriptPath -Encoding utf8

Write-Host "`nExecution script created at: $generatedScriptPath" -ForegroundColor Green
Write-Host "It is hardcoded to use the folder: $exeFolder"
Write-Host "When run, it will attempt to open the EXE files from that location."
  
# Keep the window open until the user is ready to exit.
Read-Host "Press Enter to exit"

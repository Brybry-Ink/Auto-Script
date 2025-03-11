# This file should be in .ps1 for it to work
# Example: Autoinstallscript.ps1
# Main Script: Application Selection and Generation of an Execution Script

# --- Customizes Initial Background and Foreground ---
mode con: cols=82 lines=30
$Host.ui.rawui.backgroundcolor = "Black"
$Host.ui.rawui.foregroundcolor = "white"

# --- OS Selection ---
do 
{
    Clear-Host
    Write-Host ""
    Write-Host ""
    Write-Host "      ______________________________________________________________________      "
    Write-Host ""
    Write-Host "              Select your Operating System:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "           [1] Windows"
    Write-Host "           [2] Linux"
    Write-Host ""
    Write-Host "      ______________________________________________________________________      "
    Write-Host ""
    Write-Host ""
    $userOSInput = Read-Host "               Choose a menu option using your keyboard [1 or 2] "
 
    switch ($userOSInput) 
    {
        "1" {
            $osSelection = "Windows"
            $validOS = $true
            }
        "2" {
            $osSelection = "Linux"
            $validOS = $true
            }
        Default 
        {
            Write-Host "`n                    Invalid selection. Please try again." -ForegroundColor Red
            Start-Sleep 1
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
    "Notepad ++",
    "Java 8"
            )

$selectedOptions = @()

while ($true) 
{
    Clear-Host

    # Display Available Options with Numbers
    Write-Host "Available Options:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $options.Count; $i++) 
    {
        Write-Host ("{0}. {1}" -f ($i + 1), $options[$i])
    }
    
    # Display Selected Options
    Write-Host "`nSelected Options:" -ForegroundColor Green
    if ($selectedOptions.Count -eq 0) 
    {
        Write-Host "None"
    } 
    else 
    {
        $selectedOptions | ForEach-Object { Write-Host $_ }
    }
    
    Write-Host "`nEnter the number of an option to add/remove it, or 'X' to finish:" -ForegroundColor Yellow
    $userInput = Read-Host "Your Selection"
    
    if ($userInput -match '^[Xx]$') 
    {
        break
    }
    
    if ([int]::TryParse($userInput, [ref]$null)) 
    {
        $choiceNumber = [int]$userInput
        if ($choiceNumber -ge 1 -and $choiceNumber -le $options.Count) 
        {
            $optionName = $options[$choiceNumber - 1]
            if ($selectedOptions -contains $optionName) 
            {
                $removeChoice = Read-Host "`n$optionName is already selected. Do you want to remove it? (Y/N)"
                if ($removeChoice -match '^[Yy]$')
                {
                    $selectedOptions = $selectedOptions | Where-Object { $_ -ne $optionName }
                    Write-Host "$optionName removed." -ForegroundColor Red
                }
            } 
            else 
            {
                $selectedOptions += $optionName
                Write-Host "$optionName added." -ForegroundColor Green
            }
        } 
        else 
        {
            Write-Host "Invalid number. Please select a number between 1 and $($options.Count)." -ForegroundColor Red
        }
    }
    else 
    {
        Write-Host "Invalid input. Please enter a valid number or 'X' to finish." -ForegroundColor Red
    }
    
    Start-Sleep 1
}

if ($selectedOptions.Count -eq 0) 
{
    Write-Host "No applications selected. Exiting..." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# --- Generate Windows Install Script ---
if ($osSelection -eq "Windows")
{
    $tempPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "Installer-Script.ps1")
    
    #  applications names mapped to their winget IDs
    $appFileMap = @{
        "Steam"            = "Valve.Steam"
        "Adobe Reader"     = "Adobe.Acrobat.Reader.64-bit"
        "Microsoft Teams"  = "Microsoft.Teams"
        "FireFox"          = "Mozilla.Firefox"
        "Discord"          = "Discord.Discord"
        "Google Chrome"    = "Google.Chrome"
        "Notepad ++"       = "Notepad++.Notepad++"
        "Java 8"           = "Oracle.JavaRuntimeEnvironment"
                    }


    # generate windows script content
    $scriptContent = @"
# Generated script through Auto-Script.
# This script installs selected applications using winget.
#`n

"@

    # loops through all selected applications and adds winget install commands.
    foreach ($app in $selectedOptions) 
    {
        if ($appFileMap.ContainsKey($app)) 
        {
            $wingetID = $appFileMap[$app]
            $scriptContent += "Write-Host `"Installing $app...`" -ForegroundColor Cyan`n"
            $scriptContent += "winget install --id $wingetID --silent --accept-source-agreements --accept-package-agreements`n"
            $scriptContent += "`n"
        }
    }
}
elseif ($osSelection -eq "Linux")
{
    $tempPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "Installer-Script.sh")
    
    # applications names mapped to Linux APT package names
    $appFileMap = @{
        "Steam"            = "steam"
        "Adobe Reader"     = "acroread"
        "Microsoft Teams"  = "teams"
        "FireFox"          = "firefox"
        "Discord"          = "discord"
        "Google Chrome"    = "google-chrome-stable"
        "Notepad++"        = "notepadqq"
        "Java 8"           = "openjdk-8-jdk"
                   }

    # generate linux script content
    $scriptContent = @"
#!/bin/bash
# Generated script through Auto-Script.
# This script installs selected applications using apt-get.
#
#
# Run the following command to make it executable and install the applications:`n
# Write-Host "chmod +x $tempPath && bash $tempPath"
`n`n
sudo apt update && sudo apt upgrade -y
"@

    foreach ($app in $selectedOptions)
    {
        if ($appFileMap.ContainsKey($app))
        {
            $packageName = $appFileMap[$app]
            $scriptContent += @"
echo "Installing $app..."
sudo apt install -y $packageName
`n
"@
        }
    }
}

#
# writes the generated script to the Desktop
$scriptContent | Out-File -FilePath $tempPath -Encoding utf8

if ($osSelection -eq "Linux")
{
    Write-Host "`nExecution script created at: $tempPath`n" -ForegroundColor Green
    Write-Host "Run the following command to make it executable and install the applications:"
    Write-Host "chmod +x $tempPath && bash $tempPath" -ForegroundColor Yellow
}
else
{
    Write-Host "`nExecution script created at: $tempPath`n" -ForegroundColor Green
    Write-Host "This new script will install the selected applications using Winget."
}

Read-Host "`nPress Enter to exit"



# This file should be in .ps1 for it to work
# Example: auto-script.ps1
# Main Script: Application Selection and Generation of an Execution Script

# --- Customizes Initial Background and Foreground ---
$Host.ui.rawui.backgroundcolor = "Black"
$Host.ui.rawui.foregroundcolor = "white"
$Host.UI.RawUI.WindowTitle = "Auto-Script Installer"
$Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size (83, 37)
$Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size (83, 37)
Clear-Host
$Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size (82, 36)
$Host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size (82, 36)
$Host.UI.RawUI.Clear()
Clear-Host

# --- OS Selection ---
do 
{
    Clear-Host
    Write-Host ""
    Write-Host "                                    Auto-Script"
    Write-Host "      ______________________________________________________________________      "
    Write-Host ""
    Write-Host "              Select your Operating System:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "           [1] Windows"
    Write-Host "           [2] Linux"
    Write-Host ""
    Write-Host "      ______________________________________________________________________      "
    Write-Host ""
    Write-Host "               Choose a menu option using your keyboard [1,2] :" -ForegroundColor Green
    $userOSInput = Read-Host " "
 
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
            Write-Host "                    Invalid selection. Please try again." -ForegroundColor Red
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
    Write-Host ""
    Write-Host "                                    Auto-Script"
    Write-Host "      ______________________________________________________________________      "
    Write-Host ""
    Write-Host "              Available Options:" -ForegroundColor Cyan
    Write-Host ""
    # display Available Options with Numbers
    for ($i = 0; $i -lt $options.Count; $i++) 
    {
        Write-Host ("           [{0}] {1}" -f ($i + 1), $options[$i])
    }
    
    Write-Host ""
    Write-Host "           [X] Complete Selection"
    Write-Host "           _____________________________________________________________          "
    Write-Host""
    Write-Host "              " -NoNewline
    Write-Host "Selected Options:" -ForegroundColor Cyan -NoNewline
    Write-Host "              - Click again to remove" -ForegroundColor Green
    Write-Host""
    
    # display Selected Options
    if ($selectedOptions.Count -eq 0) 
    {
        Write-Host "               None"
    }
    else 
    {
        $selectedOptions | ForEach-Object { Write-Host ("               " + $_) }
    }

    
    Write-Host "      ______________________________________________________________________      "
    Write-Host ""
    Write-Host "               Choose a menu option using your keyboard [1,2,3...8,X] :" -ForegroundColor Green
    $userInput = Read-Host " "
    
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
                Write-Host "  $optionName is already selected. Do you want to remove it? (Y/N)"
                $removeChoice = Read-Host " "
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
            Write-Host "Please enter a valid input [1,2,3...8,X]" -ForegroundColor Red
        }
    }
    else 
    {
        Write-Host "Please enter a valid input [1,2,3...8,X]" -ForegroundColor Red
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
    $tempPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "Installer-Script.ps1") # PATH GOES TO USERS TEMP FOLDER "C:\Users\Username\AppData\Local\Temp\"
    
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
else #windows excecution
{
    Write-Host "`nExecution script created at: $tempPath`n" -ForegroundColor Yellow
    Write-Host "Installing Automatically..."
    Start-Sleep 1
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File $tempPath"
}

Read-Host "`nPress Enter to exit"



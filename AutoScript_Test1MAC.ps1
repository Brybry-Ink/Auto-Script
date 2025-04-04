# Auto-Script Installer (Cross-Platform)

# --- Check if running in PowerShell Core (pwsh) ---
if ($PSVersionTable.PSEdition -ne "Core") {
    Write-Host "This script requires PowerShell Core (pwsh). Please install it first." -ForegroundColor Red
    Write-Host "For macOS/Linux: 'brew install powershell' or see https://aka.ms/powershell" -ForegroundColor Yellow
    exit 1
}

# --- Customizes Initial Background and Foreground (Windows-only) ---
if ($IsWindows) {
    $Host.UI.RawUI.BackgroundColor = "Black"
    $Host.UI.RawUI.ForegroundColor = "White"
    $Host.UI.RawUI.WindowTitle = "Auto-Script Installer"
    Clear-Host
}

# --- OS Selection ---
do {
    Clear-Host
    Write-Host ""
    Write-Host "                                    Auto-Script"
    Write-Host "      ______________________________________________________________________      "
    Write-Host ""
    Write-Host "              Select your Operating System:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "           [1] Windows"
    Write-Host "           [2] Linux"
    Write-Host "           [3] macOS"
    Write-Host ""
    Write-Host "      ______________________________________________________________________      "
    Write-Host ""
    Write-Host "               Choose a menu option using your keyboard [1,2,3] :" -ForegroundColor Green
    $userOSInput = Read-Host " "
 
    switch ($userOSInput) {
        "1" { $osSelection = "Windows"; $validOS = $true }
        "2" { $osSelection = "Linux"; $validOS = $true }
        "3" { $osSelection = "macOS"; $validOS = $true }
        default {
            Write-Host "                    Invalid selection. Please try again." -ForegroundColor Red
            Start-Sleep 1
            $validOS = $false
        }  
    }
} until ($validOS)

# --- Application Selection ---
$options = @("Steam", "Adobe Reader", "Microsoft Teams", "FireFox", "Discord", "Google Chrome", "Notepad ++", "Java 8")
$selectedOptions = @()

while ($true) {
    Clear-Host
    Write-Host ""
    Write-Host "                                    Auto-Script"
    Write-Host "      ______________________________________________________________________      "
    Write-Host ""
    Write-Host "              Available Options:" -ForegroundColor Cyan
    Write-Host ""
    for ($i = 0; $i -lt $options.Count; $i++) { Write-Host ("           [{0}] {1}" -f ($i + 1), $options[$i]) }
    Write-Host ""
    Write-Host "           [X] Complete Selection"
    Write-Host "           _____________________________________________________________          "
    Write-Host ""
    Write-Host "              " -NoNewline
    Write-Host "Selected Options:" -ForegroundColor Cyan -NoNewline
    Write-Host "              - Click again to remove" -ForegroundColor Green
    Write-Host ""

    if ($selectedOptions.Count -eq 0) { Write-Host "               None" }
    else { $selectedOptions | ForEach-Object { Write-Host ("               " + $_) } }

    Write-Host "      ______________________________________________________________________      "
    Write-Host ""
    Write-Host "               Choose a menu option using your keyboard [1,2,3...8,X] :" -ForegroundColor Green
    $userInput = Read-Host " "
    
    if ($userInput -match '^[Xx]$') { break }

    if ([int]::TryParse($userInput, [ref]$null)) {
        $choiceNumber = [int]$userInput
        if ($choiceNumber -ge 1 -and $choiceNumber -le $options.Count) {
            $optionName = $options[$choiceNumber - 1]
            if ($selectedOptions -contains $optionName) {
                Write-Host "  $optionName is already selected. Do you want to remove it? (Y/N)"
                $removeChoice = Read-Host " "
                if ($removeChoice -match '^[Yy]$') {
                    $selectedOptions = $selectedOptions | Where-Object { $_ -ne $optionName }
                    Write-Host "$optionName removed." -ForegroundColor Red
                }
            } else {
                $selectedOptions += $optionName
                Write-Host "$optionName added." -ForegroundColor Green
            }
        } else {
            Write-Host "Please enter a valid input [1,2,3...8,X]" -ForegroundColor Red
        }
    } else {
        Write-Host "Please enter a valid input [1,2,3...8,X]" -ForegroundColor Red
    }

    Start-Sleep 1
}

if ($selectedOptions.Count -eq 0) {
    Write-Host "No applications selected. Exiting..." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# --- Generate OS-specific installation script ---
if ($osSelection -eq "Windows") {
    $tempPath = Join-Path -Path $env:TEMP -ChildPath "Installer-Script.ps1"
    $appFileMap = @{
        "Steam" = "Valve.Steam"; "Adobe Reader" = "Adobe.Acrobat.Reader.64-bit";
        "Microsoft Teams" = "Microsoft.Teams"; "FireFox" = "Mozilla.Firefox";
        "Discord" = "Discord.Discord"; "Google Chrome" = "Google.Chrome";
        "Notepad ++" = "Notepad++.Notepad++"; "Java 8" = "Oracle.JavaRuntimeEnvironment"
    }
    $scriptContent = @"
# Generated script through Auto-Script.
# This script installs selected applications using winget.

"@
    foreach ($app in $selectedOptions) {
        if ($appFileMap.ContainsKey($app)) {
            $wingetID = $appFileMap[$app]
            $scriptContent += "Write-Host `"Installing $app...`" -ForegroundColor Cyan`n"
            $scriptContent += "winget install --id $wingetID --silent --accept-source-agreements --accept-package-agreements`n`n"
        }
    }
} elseif ($osSelection -eq "Linux" -or $osSelection -eq "macOS") {
    $tempPath = Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath "Installer-Script.sh"
    $appFileMap = @{
        "Steam" = "steam"; "Adobe Reader" = "acroread";
        "Microsoft Teams" = "teams"; "FireFox" = "firefox";
        "Discord" = "discord"; "Google Chrome" = "google-chrome-stable";
        "Notepad ++" = "notepadqq"; "Java 8" = "openjdk-8-jdk"
    }
    if ($osSelection -eq "macOS") {
        $appFileMap = @{
            "Steam" = "steam"; "Adobe Reader" = "adobe-acrobat-reader";
            "Microsoft Teams" = "microsoft-teams"; "FireFox" = "firefox";
            "Discord" = "discord"; "Google Chrome" = "google-chrome";
            "Notepad ++" = "visual-studio-code"; "Java 8" = "temurin8"
        }
    }
    $scriptContent = @"
#!/bin/bash
# Generated script through Auto-Script.
# This script installs selected applications.

if [[ `"$osSelection`" == `"macOS`" ]]; then
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c `"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)`"
        echo 'eval `"$(/opt/homebrew/bin/brew shellenv)`"' >> ~/.zprofile
        eval `"$(/opt/homebrew/bin/brew shellenv)`"
    fi
    brew update
    brew tap homebrew/cask
fi

"@
    foreach ($app in $selectedOptions) {
        if ($appFileMap.ContainsKey($app)) {
            $packageName = $appFileMap[$app]
            if ($osSelection -eq "Linux") {
                $scriptContent += "echo `"Installing $app...`"`nsudo apt install -y $packageName`n`n"
            } else {
                $scriptContent += "echo `"Installing $app...`"`nbrew install --cask $packageName`n`n"
            }
        }
    }
}

$scriptContent | Out-File -FilePath $tempPath -Encoding utf8

if ($osSelection -eq "Linux" -or $osSelection -eq "macOS") {
    Write-Host "`nExecution script created at: $tempPath`n" -ForegroundColor Green
    Write-Host "Run the following command to make it executable and install the applications:"
    Write-Host "chmod +x `"$tempPath`" && bash `"$tempPath`"" -ForegroundColor Yellow
} else {
    Write-Host "`nExecution script created at: $tempPath`n" -ForegroundColor Yellow
    Write-Host "Installing Automatically..."
    Start-Sleep 1
    Start-Process pwsh -ArgumentList "-ExecutionPolicy Bypass -File `"$tempPath`""
}

Read-Host "`nPress Enter to exit"

# Get-ExecutionPolicy -List
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
# if running script is giving issues then you need to change the execution policy on your pc using commands above^

# put the auto-script file on your desktop in order to run the run.ps1 script
cls
$scriptPath = Join-Path -Path $env:USERPROFILE -ChildPath 'Desktop\Auto-Script.ps1'

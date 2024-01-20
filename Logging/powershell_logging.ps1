# Define the path to the PowerShell registry key
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"

# Create the registry key if it doesn't exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}

# Enable Script Block Logging
Set-ItemProperty -Path $regPath -Name "EnableScriptBlockLogging" -Value "1"

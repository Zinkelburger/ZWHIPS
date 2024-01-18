# Stop the WinRM service
Stop-Service -Name WinRM

# Disable the WinRM service to prevent it from starting automatically
Set-Service -Name WinRM -StartupType Disabled

# Optionally, you can remove the WinRM listener
# This step is usually not necessary unless you have specific custom configurations
# Remove-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="HTTP"}
# Remove-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="HTTPS"}

Write-Host "WinRM has been disabled."

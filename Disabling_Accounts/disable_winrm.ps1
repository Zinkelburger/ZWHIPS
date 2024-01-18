# Stop the WinRM service
Stop-Service -Name WinRM -Force

# Disable the WinRM service
Set-Service -Name WinRM -StartupType Disabled

# Output the status of the WinRM service
Get-Service -Name WinRM | Format-Table Name, Status, StartType -AutoSize

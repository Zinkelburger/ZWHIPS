# Disables task scheduler
Set-Service -Name Schedule -StartupType Disabled
Stop-Service -Name Schedule

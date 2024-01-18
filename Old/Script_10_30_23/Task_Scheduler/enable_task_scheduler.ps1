# enables task scheduler
Set-Service -Name Schedule -StartupType Automatic
Start-Service -Name Schedule

# Check if OpenSSH Client is installed
$OpenSSHClient = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'

if ($OpenSSHClient -and $OpenSSHClient.State -eq 'Installed') {
    # Uninstall the OpenSSH Client
    Remove-WindowsCapability -Online -Name $OpenSSHClient.Name
    Write-Host "OpenSSH Client was installed and has now been removed."
} else {
    Write-Host "OpenSSH Client is not installed."
}

# Check if OpenSSH Server is installed
$OpenSSHServer = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

if ($OpenSSHServer -and $OpenSSHServer.State -eq 'Installed') {
    # Uninstall the OpenSSH Server
    Remove-WindowsCapability -Online -Name $OpenSSHServer.Name
    Write-Host "OpenSSH Server was installed and has now been removed."
} else {
    Write-Host "OpenSSH Server is not installed."
}
$logFile = [System.Environment]::GetFolderPath("MyDocuments") + "\ShareRemovalLog.txt"

# Create the log file if it doesn't exist
if (-not (Test-Path $logFile)) {
    New-Item -Path $logFile -ItemType File
}

# Doesn't remove shares that end with $ as default system shares end with a $
Get-SmbShare | Where-Object { $_.Name -notmatch '^\w+\$$' } | ForEach-Object {
    $shareName = $_.Name
    $sharePath = $_.Path
    
    # Get share permissions
    $permissions = Get-SmbShareAccess -Name $shareName
    $permissionsText = $permissions | ForEach-Object { "$($_.AccountName): $($_.AccessRight)" } | Out-String
    $permissionsText = $permissionsText.Trim()

    # Remove the share
    Remove-SmbShare -Name $shareName -Force

    # Log the removed share with permissions
    $logEntry = "$(Get-Date) - Removed SMB share: Name = $shareName, Path = $sharePath, Permissions: $permissionsText"
    Add-Content -Path $logFile -Value $logEntry
}

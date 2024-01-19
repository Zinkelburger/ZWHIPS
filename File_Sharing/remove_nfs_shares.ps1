# Note: this script is interactive, as I feel like it has a high potential to go wrong
$logFile = [System.Environment]::GetFolderPath("MyDocuments") + "/nfsShares.txt"

# Create the log file if it doesn't exist
if (-not (Test-Path $logFile)) {
    New-Item -Path $logFile -ItemType File
}

# Get all NFS shares
$nfsshares = Get-NfsShare

foreach ($share in $nfsshares) {
    # Prompt the user for each share
    $userConfirmation = Read-Host "Do you want to remove NFS share `"$($share.Name)`" at path `"$($share.Path)`"? [Y/N]"

    if ($userConfirmation -eq "Y") {
        # Remove the NFS share
        Remove-NfsShare -Name $share.Name -Force

        # Log the removal
        $logEntry = "$(Get-Date) - Removed NFS share: Name = $($share.Name), Path = $($share.Path)"
        Add-Content -Path $logFile -Value $logEntry

        Write-Host "Share removed and logged: $($share.Name)"
    }
    else {
        Write-Host "Share not removed: $($share.Name)"
    }
}

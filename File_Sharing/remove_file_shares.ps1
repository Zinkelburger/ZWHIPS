# Get all SMB shares
$allShares = Get-SmbShare

# Filter out only NFS shares
$sharesToRemove = $allShares | Where-Object {
    $_.ShareType -ne "NFS"
}

# Remove SMB shares
$sharesToRemove | ForEach-Object {
    Remove-SmbShare -Name $_.Name -Force
    Write-Host "Removed share: $($_.Name)"
}

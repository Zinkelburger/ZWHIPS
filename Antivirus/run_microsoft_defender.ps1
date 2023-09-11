# 1. Initiate a full scan using Windows Defender
Start-MpScan -ScanType FullScan

# Start-MpScan waits until the scan completes
# 2. Check the results and log them to the terminal
$threats = Get-MpThreat
if ($threats.Count -eq 0) {
    Write-Host "No threats detected." -ForegroundColor Green
} else {
    Write-Host "$($threats.Count) threats detected." -ForegroundColor Red
    $threats | Format-Table -Property ThreatName, SeverityID, Path, ThreatStatus
}

# 3. Remove the threats detected by Windows Defender
$threats | ForEach-Object {
    Remove-MpThreat -InputObject $_
    Write-Host "Removed threat: $($_.ThreatName)" -ForegroundColor Yellow
}

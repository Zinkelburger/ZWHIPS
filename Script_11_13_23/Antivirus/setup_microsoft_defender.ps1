# Get current preferences
$preferences = Get-MpPreference

# Remove Exclusion Paths
$preferences.ExclusionPath | ForEach-Object { Remove-MpPreference -ExclusionPath $_ }

# Remove Exclusion Processes
$preferences.ExclusionProcess | ForEach-Object { Remove-MpPreference -ExclusionProcess $_ }

# Remove Exclusion Extensions
$preferences.ExclusionExtension | ForEach-Object { Remove-MpPreference -ExclusionExtension $_ }

# Remove Exclusion IPs (if present)
if ($preferences.ExclusionIP) {
    $preferences.ExclusionIP | ForEach-Object { Remove-MpPreference -ExclusionIP $_ }
}

# Ensure Defender Realtime Monitoring is On
Set-MpPreference -DisableRealtimeMonitoring $false

# Reset Actions for Detected Threats
Set-MpPreference -RemediationSuppression 0

# Reset Cloud-delivered Protection & Automatic Sample Submission Settings to Advanced
Set-MpPreference -MAPSReporting Advanced

Write-Output "Microsoft Defender has been reset to its default state."

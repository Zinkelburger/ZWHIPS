# Script for the CCDC Practice on 10/23/23
# Prereq: You are logged in as a domain admin (not local admin) and are in the documents folder (I think)
# Add the black team acount name here so it is not removed
$excludedAccounts = @("black team") # Add any other accounts to this array if needed

# 1. Disables Task Scheduler
Set-Service -Name Schedule -StartupType Disabled
Stop-Service -Name Schedule

# 2. Disable all GPO policies not made by the system
# Define a function to set the GPO status
function SetGPOStatus([string]$GPOName, [string]$Status) {
        $gpo = Get-GPO $GPOName -ErrorAction SilentlyContinue
        if ($null -eq $gpo) {
            Write-Host "Could not locate $GPOName"
        }
        else {
            $gpo.GpoStatus = $Status
            Write-Host "Set $($gpo.DisplayName) to $($gpo.GpoStatus)"
        }
    }
    
# Microsoft module to manage Group Policy
Import-Module grouppolicy

# Identify the well-known system SID for comparison
$systemSID = (New-Object System.Security.Principal.SecurityIdentifier "S-1-5-18").Value

# Get all GPOs in the domain
$allGPOs = Get-GPO -All

# Loop through each GPO
foreach ($gpo in $allGPOs) {
        # Get the owner of the GPO
        $gpoSecurityInfo = Get-GPOReport -Name $gpo.DisplayName -ReportType xml
        $gpoOwnerSID = ([xml]$gpoSecurityInfo).GPO.SecurityDescriptor.Owner.SID

        # If the GPO owner is not the system, then disable the GPO
        if ($gpoOwnerSID -ne $systemSID) {
                SetGPOStatus $gpo.DisplayName "AllSettingsDisabled"
        }
}

# 3. Disable all local and domain accounts, except for the current user
# Disable all local user accounts
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='True'" | 
Where-Object { $_.Name -ne $currentUser.Split('\')[1] -and $excludedAccounts -notcontains $_.Name } | 
ForEach-Object {
    $username = $_.Name
    net user $username /active:no
    Write-Host "Disabled local account: $username"
}

# If ActiveDirectory module isn't loaded, try to import it
if (-not (Get-Module ActiveDirectory)) {
    try {
        Import-Module ActiveDirectory
    } catch {
        Write-Warning "Failed to import ActiveDirectory module. Make sure it's installed."
        exit
    }
}

# Disable all AD accounts except the current one and the excluded accounts
Get-ADUser -Filter * | 
Where-Object { $_.SamAccountName -ne $currentUser.Split('\')[1] -and $excludedAccounts -notcontains $_.SamAccountName } | 
ForEach-Object {
    $username = $_.SamAccountName
    Disable-ADAccount -Identity $username
    Write-Host "Disabled AD account: $username"
}

# 4. Delete Registry Keys
# Removes registry keys in common malware locations
function Remove-AutorunKey {
        param(
            [string]$Path,
            [string]$Key
        )
    
        try {
            # Fetch key value details
            $keyDetails = Get-ItemProperty -Path $Path -Name $Key
            $keyValue = $keyDetails.$Key
            
            # Print out the key contents
            Write-Host "Contents of ${Key} in ${Path}"
            Write-Host "${Key}: ${keyValue}"
            Write-Host "`n"  # Just for formatting to separate entries
    
            # Remove the specific autorun key
            Remove-ItemProperty -Path $Path -Name $Key
            Write-Host "Deleted $Key from $Path"
            Write-Host "`n"  # Just for formatting to separate entries
        } catch {
            Write-Warning "Error processing $Key in $Path"
        }
    }
    
    # Define autorun registry locations
    $autorunPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
    )
    
    # Iterate over each path and remove keys
    foreach ($path in $autorunPaths) {
        # Check if the path exists before proceeding
        if (Test-Path $path) {
            $keys = Get-ItemProperty -Path $path | 
                    ForEach-Object { $_.PSObject.Properties } |
                    Where-Object { $_.Name -ne "PSPath" -and $_.Name -ne "PSParentPath" -and $_.Name -ne "PSChildName" -and $_.Name -ne "PSDrive" -and $_.Name -ne "PSProvider" } |
                    ForEach-Object { $_.Name }
            foreach ($key in $keys) {
                Remove-AutorunKey -Path $path -Key $key
            }
        }
    }
    
    
# 5. Clear startup folders
# Clear common startup folder for all users
$commonStartupFolder = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
Remove-Item "$commonStartupFolder\*" -Recurse -Force

Write-Host "Cleared common startup folder for all users."

# Iterate through each user's startup folder and clear it
$usersProfilePath = "$env:SystemDrive\Users\"
$individualStartupFolderRelPath = "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

Get-ChildItem -Path $usersProfilePath -Directory | ForEach-Object {
    $startupFolderPath = Join-Path $_.FullName $individualStartupFolderRelPath
    if (Test-Path $startupFolderPath) {
        Remove-Item "$startupFolderPath\*" -Recurse -Force
        Write-Host "Cleared startup folder for user $($_.Name)."
    }
}

# 6. remove restrictions on microsoft defender
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

# 7. Enumerate task scheduler into a csv file
outputPath = Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "taskSchedulerOutput.csv"

Get-ScheduledTask | ForEach-Object {
    Get-ScheduledTaskInfo -TaskPath $_.TaskPath -TaskName $_.TaskName
    $actions = $_.Actions

    [PSCustomObject]@{
        'TaskName'     = $_.TaskName
        'TaskPath'     = $_.TaskPath
        'Description'  = $_.Description
        'State'        = $_.State
        'Actions'      = ($actions | ForEach-Object { $_.Execute }) -join '; '
        'Arguments'    = ($actions | ForEach-Object { $_.Arguments }) -join '; '
    }
} | Export-Csv -Path $outputPath -NoTypeInformation

# 8. Configure the firewall
# Reset the firewall rules
Get-NetFirewallRule | Remove-NetFirewallRule
Write-Host "All firewall rules have been reset."

# Configure the firewall
# Deny all inbound
Set-NetFirewallProfile -DefaultInboundAction Block

# Allow necessary AD Traffic
$allowedInboundPorts = @(53, 88, 123, 389, 445, 636, 3268) # Add other necessary ports
foreach ($port in $allowedInboundPorts) {
    New-NetFirewallRule -DisplayName "Allow AD Traffic $port" -Direction Inbound -LocalPort $port -Action Allow
}

# Deny all outbound
Set-NetFirewallProfile -DefaultOutboundAction Block

# Allow necessary outbound traffic
$allowedOutboundPorts = @(53, 88, 123, 389, 445, 636, 3268, 3269) # Add other necessary ports
foreach ($port in $allowedOutboundPorts) {
    New-NetFirewallRule -DisplayName "Allow Outbound Traffic $port" -Direction Outbound -LocalPort $port -Action Allow
}

Write-Host "Firewall configured."

# 9. Remove file shares
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

# 10. View file shares
net share





# Script for the CCDC Practice on 10/30/23
# 1. Disable task scheduler
# Disables task scheduler
Set-Service -Name Schedule -StartupType Disabled
Stop-Service -Name Schedule

# 2. Disable all accounts besides black team & domain admin
# Disable all local user accounts
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$excludedAccounts = @("black team") # Add any other accounts to this array if needed

Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='True'" | 
Where-Object { $_.Name -ne $currentUser.Split('\')[1] -and $excludedAccounts -notcontains $_.Name } | 
ForEach-Object {
    $username = $_.Name
    net user $username /active:no
    Write-Host "Disabled local account: $username"
}

# If ActiveDirectory module isn't loaded, try to import it
$ActiveDirectoryModuleAvailable = $true
if (-not (Get-Module ActiveDirectory)) {
    try {
        Import-Module ActiveDirectory
    } catch {
        Write-Warning "Failed to import ActiveDirectory module. Make sure it's installed."
        $ActiveDirectoryModuleAvailable = $false
    }
}

# Disable all AD accounts except the current one and the excluded accounts, only if ActiveDirectory module is available
if ($ActiveDirectoryModuleAvailable) {
    try {
        Get-ADUser -Filter * | 
        Where-Object { $_.SamAccountName -ne $currentUser.Split('\')[1] -and $excludedAccounts -notcontains $_.SamAccountName } | 
        ForEach-Object {
            $username = $_.SamAccountName
            Disable-ADAccount -Identity $username
            Write-Host "Disabled AD account: $username"
        }
    } catch {
        Write-Warning "Failed to disable AD accounts. Make sure you have the necessary permissions."
    }
}

# 3. Logoff the users we disabled
# Check if ActiveDirectory module is available
if (Get-Module -ListAvailable -Name ActiveDirectory) {
        # Import the Active Directory module
        Import-Module ActiveDirectory

        # Get all disabled users
        $disabledUsers = Get-ADUser -Filter 'Enabled -eq $false' | Select-Object -ExpandProperty SamAccountName

        # For each disabled user
        foreach ($user in $disabledUsers) {
                # Get the session ID of the user
                $sessionId = ((quser | Where-Object { $_ -match $user }) -split ' +')[2]
                
                # If the session ID exists, log off the user
                if ($sessionId) {
                        logoff $sessionId
                }
        }
}
    
# Get all local users
$localUsers = Get-LocalUser

# For each local user
foreach ($user in $localUsers) {
        # If the user is disabled
        if ($user.Enabled -eq $false) {
                # Get the session ID of the user
                $sessionId = ((quser | Where-Object { $_ -match $user.Name }) -split ' +')[2]
                
                # If the session ID exists, log off the user
                if ($sessionId) {
                        logoff $sessionId
                }
        }
}

# 4. Clear Startup Folders
# Define common startup folder for all users
$commonStartupFolder = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"

# Define the destination folder
$destinationFolder = "$env:USERPROFILE\Documents\StartupFolder"

# Create the destination folder if it doesn't exist
if (!(Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

# Move all files from common startup folder to the destination folder
Get-ChildItem -Path $commonStartupFolder | ForEach-Object {
    Write-Host "Moving file $($_.FullName) to $destinationFolder"
    Move-Item -Path $_.FullName -Destination $destinationFolder
}

# Clear common startup folder for all users
Remove-Item "$commonStartupFolder\*" -Recurse -Force

Write-Host "Cleared common startup folder for all users."

# Iterate through each user's startup folder and clear it
$usersProfilePath = "$env:SystemDrive\Users\"
$individualStartupFolderRelPath = "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

Get-ChildItem -Path $usersProfilePath -Directory | ForEach-Object {
    $startupFolderPath = Join-Path $_.FullName $individualStartupFolderRelPath
    if (Test-Path $startupFolderPath) {
        # Move all files from the user's startup folder to the destination folder
        Get-ChildItem -Path $startupFolderPath | ForEach-Object {
            Write-Host "Moving file $($_.FullName) to $destinationFolder"
            Move-Item -Path $_.FullName -Destination $destinationFolder
        }
        
        # Clear the user's startup folder
        Remove-Item "$startupFolderPath\*" -Recurse -Force
        
        Write-Host "Cleared startup folder for user $($_.Name)."
    }
}

# 5. Delete autorun registry keys
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
    
# 6. Remove all network shares, besides NFS
# Get all SMB shares
$allShares = Get-SmbShare

# Filter out only NFS shares
$sharesToRemove = $allShares | Where-Object {
    $_.ShareType -ne "NFS"
}

# Remove SMB shares
$sharesToRemove | ForEach-Object {
    Write-Host "Removing share: $($_.Name)"
    Remove-SmbShare -Name $_.Name -Force
    Write-Host "Removed share: $($_.Name)"
}

# 7. WDigest authentication retains plaintext passwords in memory
reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest /v UseLogonCredential /t REG_DWORD /d 0 /f

# 8. Delete all exes not signed my microsoft, kill process, move to folder
# Requires -RunAsAdministrator

# Define the folder where potential malware will be moved
$PotentialMalwareDir = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "PotentialMalware")

# Create the directory if it doesn't exist
if (-not (Test-Path -Path $PotentialMalwareDir)) {
    New-Item -ItemType Directory -Path $PotentialMalwareDir | Out-Null
}

# Log file location
$LogFile = "$PotentialMalwareDir\MalwareLog.txt"

# Scan the system for executables
$Executables = Get-ChildItem -Path C:\ -Include *.exe -Recurse -ErrorAction SilentlyContinue

foreach ($Executable in $Executables) {
    # Skip if the file is not an executable or is part of the Windows folder
    if ($Executable.DirectoryName -like "C:\Windows*") {
        continue
    }

    # Check if the file is signed and the signer is not Microsoft
    $Signature = Get-AuthenticodeSignature -FilePath $Executable.FullName
    if ($Signature.Status -ne "Valid" -or $Signature.SignerCertificate -notlike "*Microsoft Corporation*") {
        # Attempt to kill the process if running
        $Process = Get-Process | Where-Object { $_.Path -eq $Executable.FullName }
        if ($Process) {
            Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue
        }

        # Log the original location of the executable
        Add-Content -Path $LogFile -Value "Moved Malicious File: $($Executable.FullName) to $PotentialMalwareDir"

        # Move the file to the PotentialMalware directory
        Move-Item -Path $Executable.FullName -Destination $PotentialMalwareDir -Force -ErrorAction SilentlyContinue
    }
}

# Outputs the content of the log file to the console
Get-Content -Path $LogFile




    
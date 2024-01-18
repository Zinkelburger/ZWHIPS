# 1. Disable all local & domain accounts, log them off
# 2. Clear startup folders, move to a folder
# 3. Delete registry autorun keys
# 4. Delete from all desktops, move to a folder
# 5. WDigest authentication retains plaintext passwords in memory
# 6. Remove all network shares, besides NFS
# 7. Remove all exes not signed by microsoft, kill process, move to folder
# 8. Set DNS to the default, log the DNS to a file

# 1. Disable all local & domain account
# Disable all local user accounts
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$excludedAccounts = @("black-team") # Add any other accounts to this array if needed

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

# Logoff the users we disabled
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

# 2. Clear startup folders
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

# 3. Delete registry autoruns
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

# 4. move desktops
# move all files in desktops to a folder in Documents.
# Get the current administrator user's 'My Documents' path
$adminDocuments = [System.Environment]::GetFolderPath("MyDocuments")

# Define the root path where the desktops will be stored
$initialDesktopPath = Join-Path -Path $adminDocuments -ChildPath "InitialDesktop"

# Create the InitialDesktop directory if it doesn't exist
if (-not (Test-Path -Path $initialDesktopPath)) {
    New-Item -ItemType Directory -Path $initialDesktopPath
}

# Get all user profiles excluding system profiles
$userProfiles = Get-ChildItem -Path "C:\Users" | Where-Object {
    $_.PSIsContainer -and $_.Name -notmatch "^(Default|Public|All Users|Default User.*)$"
}

foreach ($user in $userProfiles) {
    $userDesktopPath = Join-Path -Path $user.FullName -ChildPath "Desktop"
    $targetUserFolder = Join-Path -Path $initialDesktopPath -ChildPath ($user.Name + "_Desktop")
    
    if (-not (Test-Path -Path $targetUserFolder)) {
        New-Item -ItemType Directory -Path $targetUserFolder
    }

    if (Test-Path -Path $userDesktopPath) {
        Move-Item -Path $userDesktopPath\* -Destination $targetUserFolder -Force
    }
}

# Handle the Public Desktop
$publicDesktopPath = "C:\Users\Public\Desktop"
$targetPublicFolder = Join-Path -Path $initialDesktopPath -ChildPath "PublicDesktop"

if (-not (Test-Path -Path $targetPublicFolder)) {
    New-Item -ItemType Directory -Path $targetPublicFolder
}

if (Test-Path -Path $publicDesktopPath) {
    Move-Item -Path $publicDesktopPath\* -Destination $targetPublicFolder -Force
}

Write-Host "Desktops have been moved to the InitialDesktop directory."

# 5. WDigest
reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest /v UseLogonCredential /t REG_DWORD /d 0 /f

# 6. Remove network shares
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

# 7. remove all exes not signed by microsoft, kill process, move to folder
# Define the quarantine directory
$QuarantineDir = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "Quarantine")

# Create the directory if it doesn't exist
if (-not (Test-Path -Path $QuarantineDir)) {
    New-Item -ItemType Directory -Path $QuarantineDir | Out-Null
}

# Log file location
$LogFile = "$QuarantineDir\QuarantineLog.txt"

# Scan the system for executables
$Executables = Get-ChildItem -Path C:\ -Include *.exe -Recurse -ErrorAction SilentlyContinue

foreach ($Executable in $Executables) {
    # Skip files in the Windows directory
    # if ($Executable.FullName -like "C:\Windows*") {
        # continue
    # }

    # Check if the file is signed by Microsoft
    $Signature = Get-AuthenticodeSignature -FilePath $Executable.FullName
    if ($Signature.Status -ne "Valid" -or $Signature.SignerCertificate -notlike "*Microsoft Corporation*") {
        # Attempt to kill the process if it is running
        $Process = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $Executable.FullName }
        if ($Process) {
            Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue
        }

        # Log the original location and move the file
        $logEntry = "File: $($Executable.FullName), OriginalPath: $($Executable.DirectoryName)"
        Add-Content -Path $LogFile -Value $logEntry
        $QuarantinePath = Join-Path -Path $QuarantineDir -ChildPath $Executable.Name
        Move-Item -Path $Executable.FullName -Destination $QuarantinePath -Force
    }
}

# 8. Set DNS to default, log to a file
# Define the path to the current user's Documents directory
$DocumentsPath = [System.Environment]::GetFolderPath("MyDocuments")

# Define the path to the hosts file
$HostsFilePath = "C:\Windows\System32\drivers\etc\hosts"

# Define the path for the backup copy
$BackupPath = Join-Path -Path $DocumentsPath -ChildPath "hosts_backup.txt"

# Copy the hosts file to the user's Documents directory
Copy-Item -Path $HostsFilePath -Destination $BackupPath -Force

# Reset the hosts file to default
$defaultHostsContent = @"
127.0.0.1       localhost
::1             localhost
"@

# Overwrite the hosts file with the default content
Set-Content -Path $HostsFilePath -Value $defaultHostsContent -Force

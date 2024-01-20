# 1. Delete Registry Keys
# 2. Delete startup folders
# 3. Not Signed Exes
# 4. Delete all Desktops

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
    
    
# 2. Delete startup folders
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

# 3. Not Signed Exes
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

# 4. Delete all desktops
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




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

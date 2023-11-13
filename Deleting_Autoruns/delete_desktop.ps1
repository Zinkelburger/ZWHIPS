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

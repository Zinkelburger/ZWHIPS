# PowerShell script to move files to the current user's MyDocuments\Netlogon
# Probably should only be run on the domain controller

# Define source directories
$SourceDirs = @(
    Join-Path $env:SystemRoot "System32\Repl\Imports\Scripts",
    Join-Path $env:SystemRoot "System32\GroupPolicy\User\Scripts\Logon"
)

# Define destination directory using the current user's MyDocuments path
$DestDir = [System.Environment]::GetFolderPath('MyDocuments') + "\Netlogon"

# Create the destination directory if it doesn't exist
if (-not (Test-Path $DestDir)) {
    New-Item -ItemType Directory -Path $DestDir
}

# Loop through each source directory and move the files
foreach ($SourceDir in $SourceDirs) {
    if (Test-Path $SourceDir) {
        Get-ChildItem $SourceDir | Move-Item -Destination $DestDir
    } else {
        Write-Warning "Source directory not found: $SourceDir"
    }
}

# PowerShell script to move files from the Imports/Scripts to the current user's MyDocuments\Netlogon
# Can only be run on the domain controller

# Define source directory
$SourceDir = Join-Path $env:SystemRoot "System32\Repl\Imports\Scripts"

# Define destination directory using the current user's MyDocuments path
$DestDir = [System.Environment]::GetFolderPath('MyDocuments') + "\Netlogon"

# Create the destination directory if it doesn't exist
if (-not (Test-Path $DestDir)) {
    New-Item -ItemType Directory -Path $DestDir
}

# Move the files
Get-ChildItem $SourceDir | Move-Item -Destination $DestDir

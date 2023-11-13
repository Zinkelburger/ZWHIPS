# Define the quarantine directory
$QuarantineDir = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "Quarantine")

# Log file location
$LogFile = "$QuarantineDir\QuarantineLog.txt"

# Check if the log file exists
if (Test-Path -Path $LogFile) {
    # Read the log file
    $LogEntries = Get-Content -Path $LogFile

    foreach ($LogEntry in $LogEntries) {
        # Extract the file path and original path
        $FilePath, $OriginalPath = $LogEntry -replace 'File: ', '' -split ', OriginalPath: '
        $FileName = [System.IO.Path]::GetFileName($FilePath)
        $QuarantineFilePath = Join-Path -Path $QuarantineDir -ChildPath $FileName

        # Move the file back to its original path
        if (Test-Path -Path $QuarantineFilePath) {
            Move-Item -Path $QuarantineFilePath -Destination $OriginalPath -Force
        }
    }

    # Optionally clear the log file after restoring files
    Clear-Content -Path $LogFile
} else {
    Write-Host "Quarantine log file does not exist or is empty."
}

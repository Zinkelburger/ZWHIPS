# Requires -RunAsAdministrator

# Define the folder where potential malware will be moved
$PotentialMalwareDir = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "PotentialMalware")

# Create the directory if it doesn't exist
if (-not (Test-Path -Path $PotentialMalwareDir)) {
    New-Item -ItemType Directory -Path $PotentialMalwareDir | Out-Null
}

# Log file location
$LogFile = "$PotentialMalwareDir\MalwareLog.txt"

# Scan the system for executables and scr (which are also exes)
$Executables = Get-ChildItem -Path C:\ -Include *.exe, *.scr -Recurse -ErrorAction SilentlyContinue

foreach ($Executable in $Executables) {
    # Check if the item is a file
    if ($Executable -is [System.IO.FileInfo]) {
        $Signature = Get-AuthenticodeSignature -FilePath $Executable.FullName
        if ($Signature.Status -ne "Valid" -or $Signature.SignerCertificate -notmatch "Microsoft Corporation|Wazuh|Mozilla|Sysinternals|Amazon|Norton") {
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
}

# Outputs the content of the log file to the console
Get-Content -Path $LogFile

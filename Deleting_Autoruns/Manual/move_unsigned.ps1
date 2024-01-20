# Define the target directory for moved executables and log file
$targetDir = "$env:USERPROFILE\Documents\Services"
$logFile = "$targetDir\services.txt"

# Create the directory if it doesn't exist
if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir
}

# Function to check if the executable is signed by Microsoft
function IsMicrosoftSigned {
    param($path)
    $signature = Get-AuthenticodeSignature -FilePath $path
    return $signature.SignerCertificate -and $signature.SignerCertificate.Issuer -like "*Microsoft*"
}

# Get all services
$services = Get-WmiObject Win32_Service

foreach ($service in $services) {
    # Extract the executable path
    $exePath = $service.PathName -replace '^(.+"|\s).*$', ''
    
    # Check if the PathName is valid and exists
    if ($exePath -and (Test-Path $exePath)) {
        $isSigned = IsMicrosoftSigned -path $exePath

        # If the executable is not signed by Microsoft, move the executable
        if (-not $isSigned) {
            # Define new path
            $newPath = Join-Path -Path $targetDir -ChildPath ([IO.Path]::GetFileName($exePath))
            
            # Move the executable
            Move-Item -Path $exePath -Destination $newPath -Force

            # Log the activity
            "$($service.Name) - $exePath -> $newPath" | Out-File -FilePath $logFile -Append
        }
    }
}

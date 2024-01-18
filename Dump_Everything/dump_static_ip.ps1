# Create the Dump folder in the user's Documents directory
$folderPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "Dump")
If (!(Test-Path -Path $folderPath )) {
    New-Item -ItemType Directory -Force -Path $folderPath
}

# Get the IP Address
$ipAddress = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.PrefixOrigin -eq "Manual" } | Select-Object -ExpandProperty IPAddress

# Check if a static IP is not found
If (-not $ipAddress) {
    $dynamicIPAddress = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "Loopback*" } | Select-Object -ExpandProperty IPAddress
    $ipAddress = $dynamicIPAddress + " (not a static ip)"
}

# Save the IP Address to a file
$ipAddress | Out-File -FilePath "$folderPath\ip.txt"

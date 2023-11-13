# Installs and extracts Kaspersky Virus Removal Tool
# download URL and the destination path
$url = "https://devbuilds.s.kaspersky-labs.com/devbuilds/KVRT/latest/full/KVRT.exe"

$destination = "$env:USERPROFILE\Downloads\kvrt.exe"

# Download the installer
Invoke-WebRequest -Uri $url -OutFile $destination

# Run the installer
Start-Process -FilePath $destination

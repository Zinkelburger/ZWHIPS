# Installs and extracts Norton Power Eraser
# download URL and the destination path
$url = "https://www.norton.com/npe_latest"
$destination = "$env:USERPROFILE\Downloads\NPE.exe"

# Download the installer
Invoke-WebRequest -Uri $url -OutFile $destination

# Run the installer
Start-Process -FilePath $destination -ArgumentList "/SILENT"

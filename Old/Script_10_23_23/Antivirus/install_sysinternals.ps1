# Installs and extracts Sysinternals Suite

# Download URL and the destination path
$url = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
$destination = "C:\Users\administrator\Downloads\SysinternalsSuite.zip"
$extractPath = "C:\Users\administrator\Documents\Sysinternals"

# Download the zip file
Invoke-WebRequest -Uri $url -OutFile $destination

# Extract the zip file
Expand-Archive -Path $destination -DestinationPath $extractPath
# Define the path to the output file in the user's Documents folder
$outputFilePath = [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "dns_servers.txt")

# Get all network adapters and their DNS server information
$dnsServers = Get-DnsClientServerAddress | Where-Object { $_.AddressFamily -eq 'IPv4' }

# Write the DNS server addresses to the file
$dnsServers | ForEach-Object {
    $_.ServerAddresses | Out-File -FilePath $outputFilePath -Append
}

# Output a confirmation message
Write-Host "DNS server information has been saved to $outputFilePath"

# Reset the firewall rules
Get-NetFirewallRule | Remove-NetFirewallRule
Write-Host "All firewall rules have been reset."

# Configure the firewall
# Deny all inbound
Set-NetFirewallProfile -DefaultInboundAction Block

# Allow necessary AD Traffic
$allowedInboundPorts = @(53, 88, 123, 389, 445, 636, 3268) # Add other necessary ports
foreach ($port in $allowedInboundPorts) {
    New-NetFirewallRule -DisplayName "Allow AD Traffic $port" -Direction Inbound -LocalPort $port -Action Allow
}

# Deny all outbound
Set-NetFirewallProfile -DefaultOutboundAction Block

# Allow necessary outbound traffic
$allowedOutboundPorts = @(53, 88, 123, 389, 445, 636, 3268, 3269) # Add other necessary ports
foreach ($port in $allowedOutboundPorts) {
    New-NetFirewallRule -DisplayName "Allow Outbound Traffic $port" -Direction Outbound -LocalPort $port -Action Allow
}

Write-Host "Firewall configured."

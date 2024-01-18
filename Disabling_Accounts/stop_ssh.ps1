Stop-Service sshd

# Get all firewall rules related to TCP port 22
$rules = Get-NetFirewallRule | Where-Object { $_.DisplayGroup -eq 'OpenSSH Server' }

# Remove each found rule
foreach ($rule in $rules) {
    Remove-NetFirewallRule -DisplayName $rule.DisplayName
    Write-Host "Removed firewall rule: $($rule.DisplayName)"
}

# Confirmation message
Write-Host "All firewall rules related to TCP port 22 have been removed."

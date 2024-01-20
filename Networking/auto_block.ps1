# Cam add this to task scheduler, or as a powershell job
# Create a firewall rule to block inbound RDP connections from the specified IP addresses
New-NetFirewallRule -DisplayName "BlockRDPBruteForce" –RemoteAddress 1.1.1.1 -Direction Inbound -Protocol TCP –LocalPort 3389 -Action Block

# Collect the list of IP addresses with more than 40 failed authentication attempts in the last hour
$Last_n_Hours = [DateTime]::Now.AddHours(-1)
$badRDPlogons = Get-EventLog -LogName 'Security' -after $Last_n_Hours -InstanceId 4625 | ?{$_.Message -match 'logon type:\s+(3)\s'} | Select-Object @{n='IpAddress';e={$_.ReplacementStrings[-2]} }
$getip = $badRDPlogons | group-object -property IpAddress | where {$_.Count -gt 40} | Select -property Name

# Add all found IP addresses of attackers to the firewall rule BlockRDPBruteForce
$log = "C:\\ps\\rdp_blocked_ip.txt"
$current_ips = (Get-NetFirewallRule -DisplayName "BlockRDPBruteForce" | Get-NetFirewallAddressFilter ).RemoteAddress
foreach ($ip in $getip)
{
    $current_ips += $ip.name
    (Get-Date).ToString() + ' ' + $ip.name + ' The IP address has been blocked due to ' + ($badRDPlogons | where {$_.IpAddress -eq $ip.name}).count + ' attempts for 2 hours'>> $log # writing the IP blocking event to the log file
}
Set-NetFirewallRule -DisplayName "BlockRDPBruteForce" -RemoteAddress $current_ips

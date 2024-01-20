Register-ScheduledJob -Name "BlockRDPBruteForceJob" -ScriptBlock {
    New-NetFirewallRule -DisplayName "BlockRDPBruteForce" -RemoteAddress 1.1.1.1 -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Block
    $Last_n_Hours = [DateTime]::Now.AddHours(-1)
    $badRDPlogons = Get-EventLog -LogName 'Security' -after $Last_n_Hours -InstanceId 4625 | ?{ $_.Message -match 'logon type:\s+(3)\s' } | Select-Object @{n='IpAddress';e={$_.ReplacementStrings[-2]}}
    $getip = $badRDPlogons | group-object -property IpAddress | where {$_.Count -gt 40} | Select -property Name
    $log = "C:\\ps\\rdp_blocked_ip.txt"
    $current_ips = (Get-NetFirewallRule -DisplayName "BlockRDPBruteForce" | Get-NetFirewallAddressFilter).RemoteAddress
    foreach ($ip in $getip) {
        $current_ips += $ip.name
        (Get-Date).ToString() + ' ' + $ip.name + ' The IP address has been blocked due to ' + ($badRDPlogons | where {$_.IpAddress -eq $ip.name}).count + ' attempts for 2 hours' >> $log
    }
    Set-NetFirewallRule -DisplayName "BlockRDPBruteForce" -RemoteAddress $current_ips
} -Trigger (New-JobTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue))

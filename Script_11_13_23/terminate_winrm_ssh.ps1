# PowerShell script to terminate all WinRM and SSH sessions

# Define a function to find and terminate WinRM sessions
Function Terminate-WinRMSessions {
    Restart-Service WinRM
}

# Define a function to find and terminate SSH sessions
Function Terminate-SSHSessions {
    # Get the list of processes that are SSH sessions
    $sshSessions = Get-Process | Where-Object { $_.Name -eq 'sshd' -or $_.Name -eq 'ssh' }

    # Terminate each SSH session
    foreach ($session in $sshSessions) {
        Stop-Process -Id $session.Id -Force
        Write-Output "SSH session terminated: $($session.Id)"
    }
}

# Invoke the functions
Terminate-WinRMSessions
Terminate-SSHSessions

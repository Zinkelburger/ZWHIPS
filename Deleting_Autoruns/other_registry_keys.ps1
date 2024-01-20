# Ensure the script is run with administrative privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Please run this script as an Administrator!"
    Break
}

# 1. Local Account Token Filter Policy
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 0 -Type DWord

# 2. Disable LM and NTLMv1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 5 -Type DWord

# 3. Enable Secure RPC
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\RPC" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\RPC" -Name "RestrictRemoteClients" -Value 1 -Type DWord

# 4. Disable Server Message Block (SMB) v1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0 -Type DWord

# 5. Disable Guest Account
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Name "Guest" -Value 0 -Type DWord

# 6. Restrict Anonymous Access
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymous" -Value 1 -Type DWord

# 7. User Account Control (UAC) Settings
# Run all administrators in Admin Approval Mode
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1 -Type DWord

# Behavior of the elevation prompt for administrators in Admin Approval Mode
# Setting to prompt for consent on secure desktop
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2 -Type DWord

# Behavior of the elevation prompt for standard users
# Setting to prompt for credentials
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorUser" -Value 1 -Type DWord

# Prevent system from storing credentials in memory
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 0 -Type DWord

Write-Host "Registry settings have been updated for enhanced security."

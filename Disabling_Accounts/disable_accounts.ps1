# Disable all local user accounts
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$excludedAccounts = @("black team") # Add any other accounts to this array if needed

Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='True'" | 
Where-Object { $_.Name -ne $currentUser.Split('\')[1] -and $excludedAccounts -notcontains $_.Name } | 
ForEach-Object {
    $username = $_.Name
    net user $username /active:no
    Write-Host "Disabled local account: $username"
}

# If ActiveDirectory module isn't loaded, try to import it
$ActiveDirectoryModuleAvailable = $true
if (-not (Get-Module ActiveDirectory)) {
    try {
        Import-Module ActiveDirectory
    } catch {
        Write-Warning "Failed to import ActiveDirectory module. Make sure it's installed."
        $ActiveDirectoryModuleAvailable = $false
    }
}

# Disable all AD accounts except the current one and the excluded accounts, only if ActiveDirectory module is available
if ($ActiveDirectoryModuleAvailable) {
    try {
        Get-ADUser -Filter * | 
        Where-Object { $_.SamAccountName -ne $currentUser.Split('\')[1] -and $excludedAccounts -notcontains $_.SamAccountName } | 
        ForEach-Object {
            $username = $_.SamAccountName
            Disable-ADAccount -Identity $username
            Write-Host "Disabled AD account: $username"
        }
    } catch {
        Write-Warning "Failed to disable AD accounts. Make sure you have the necessary permissions."
    }
}

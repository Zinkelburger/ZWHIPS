Import-Module ActiveDirectory

$serviceAccounts = Get-ADUser -Filter * -Properties Name

# Users to exclude
$excludeUsers = @("Administrator", "krbtgt", "black team")

foreach ($account in $serviceAccounts) {
    if ($account.Name -notin $excludeUsers) {
        $answer = Read-Host "Is $($account.Name) a service account? (y/n)"
        if ($answer -eq "y") {
            $newPassword = [System.Web.Security.Membership]::GeneratePassword(20, 2)
            $securePassword = ConvertTo-SecureString $newPassword -AsPlainText -Force
            Set-ADAccountPassword -Identity $account -NewPassword $securePassword -Reset
            Write-Host "Password for $($account.Name) has been changed to a random strong password."
        }
    }
}

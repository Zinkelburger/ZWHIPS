# Pretty sure this doesn't work
# PowerShell script for mapping service accounts to a service

# Import Active Directory module
Import-Module ActiveDirectory

# Function to find SPNs associated with a service account
function Find-ServiceAccountSPNs {
    param (
        [string]$AccountName
    )

    try {
        $spns = Get-ADUser -Identity $AccountName -Properties ServicePrincipalName | Select-Object -ExpandProperty ServicePrincipalName
        return $spns
    } catch {
        Write-Host "Error finding SPNs for $AccountName"
    }
}

# Retrieve all user accounts
$allUsers = Get-ADUser -Filter *

# Filter for service accounts based on your criteria (e.g., naming convention)
$serviceAccounts = $allUsers | Where-Object { $_.Name -like "serviceAccountConvention*" }

# Initialize array to hold account-service mappings
$accountServiceMappings = @()

# Find SPNs for each service account and map them
foreach ($account in $serviceAccounts) {
    $spns = Find-ServiceAccountSPNs -AccountName $account.SamAccountName
    foreach ($spn in $spns) {
        $obj = New-Object PSObject -Property @{
            AccountName    = $account.Name
            SamAccountName = $account.SamAccountName
            SPN            = $spn
        }
        $accountServiceMappings += $obj
    }
}

# Output the results to a CSV file
$csvPath = "$env:USERPROFILE\Documents\Service_Account_SPN_Mappings.csv"
$accountServiceMappings | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Service account SPN mappings have been saved to $csvPath"

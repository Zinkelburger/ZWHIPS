# prerequisite: the service accounts have been mapped to a csv in map_service_accounts_csv.ps1

# PowerShell script to map services to their potential service accounts and output to CSV

# Function to find service accounts associated with a given service
function Find-ServiceAccounts {
    param (
        [string]$ServiceName
    )

    # Query Active Directory for service accounts associated with the service
    $serviceAccounts = Get-ADUser -Filter {ServicePrincipalName -like "*$ServiceName*"} | Select-Object Name, SamAccountName

    # Return the service accounts
    return $serviceAccounts
}

# Import Active Directory module
Import-Module ActiveDirectory

# Get a list of all services on the machine
$allServices = Get-Service | Select-Object -ExpandProperty DisplayName

# Initialize an array to hold service-account mappings
$serviceAccountMappings = @()

# Loop through each service and find associated service accounts
foreach ($service in $allServices) {
    # Allow the user to select a service
    $userInput = Read-Host "Do you want to find service accounts for the service '$service'? (yes/no)"
    if ($userInput -eq 'yes') {
        $accounts = Find-ServiceAccounts -ServiceName $service
        foreach ($account in $accounts) {
            $obj = New-Object PSObject -Property @{
                ServiceName = $service
                AccountName = $account.Name
                SamAccountName = $account.SamAccountName
            }
            $serviceAccountMappings += $obj
        }
    }
}

# Output the results to a CSV file
$csvPath = "$env:USERPROFILE\Desktop\Service_Account_Mappings.csv"
$serviceAccountMappings | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Service account mappings have been saved to $csvPath"


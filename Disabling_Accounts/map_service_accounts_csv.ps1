# PowerShell script for mapping service accounts to a service

# Function to find service accounts associated with a given service
function Find-ServiceAccounts {
    param (
        [string]$ServiceName
    )

    # Query Active Directory for service accounts associated with the service
    $serviceAccounts = Get-ADUser -Filter {ServicePrincipalName -like "*$ServiceName*"} | Select-Object Name, SamAccountName

    # Output the results to a CSV file
    $csvPath = "$env:USERPROFILE\Desktop\Service_Account_Mappings.csv"
    $serviceAccounts | Export-Csv -Path $csvPath -NoTypeInformation

    Write-Host "Service account mappings have been saved to $csvPath"
}

# Import Active Directory module
Import-Module ActiveDirectory

# Prompt for the service name
$serviceName = Read-Host "Enter the name of the service"

# Execute the function
Find-ServiceAccounts -ServiceName $serviceName

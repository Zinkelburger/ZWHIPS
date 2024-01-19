# To mitigate golden ticket attacks, change the password of the krbtgt user
# Microsoft recommends changing the krbtgt account password twice. 
# This is because the Kerberos protocol uses two keys derived from this password: one current key and one historical key. 
function Reset-KrbtgtPassword {
    # Get the krbtgt account
    $krbtgtAccount = Get-ADUser -Filter {Name -eq "krbtgt"}

    # Generate a new random password
    $newPassword = [System.Web.Security.Membership]::GeneratePassword(20, 2)

    # Reset the krbtgt account password
    Set-ADAccountPassword -Identity $krbtgtAccount -NewPassword (ConvertTo-SecureString -AsPlainText $newPassword -Force)

    Write-Host "krbtgt password has been reset."
}

# Import Active Directory module
Import-Module ActiveDirectory

# Check if the script is running with administrative privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run this script as an Administrator."
    Exit
}

# Execute the password reset function twice with a delay
Reset-KrbtgtPassword
Start-Sleep -Seconds 30 # Wait 30 seconds for replication to other domain controllers
Reset-KrbtgtPassword

Write-Host "krbtgt password reset process complete."
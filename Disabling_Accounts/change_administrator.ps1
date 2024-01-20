Import-Module ActiveDirectory
$newPassword = Read-Host "Enter new password" -AsSecureString
Set-ADAccountPassword -Identity "administrator" -NewPassword $newPassword -Reset

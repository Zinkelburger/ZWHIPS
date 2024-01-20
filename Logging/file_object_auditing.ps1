# Define the path to the folder to audit
$folderPath = "C:\SensitiveData"

# Define the audit rule (Success and Failure)
$auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule("Everyone", "FullControl", "None", "None", "Success,Failure")

# Get the current ACL of the folder
$acl = Get-Acl $folderPath

# Add the audit rule to the ACL
$acl.AddAuditRule($auditRule)

# Set the updated ACL back on the folder
Set-Acl -Path $folderPath -AclObject $acl

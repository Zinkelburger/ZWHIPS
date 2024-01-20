# Load the security policy module
Import-Module secpol.msc

# Define the audit categories to enable
$auditCategories = @(
    "AuditAccountLogon",
    "AuditAccountManagement",
    "AuditLogon",
    "AuditPolicyChange"
)

# Enable auditing for each category
foreach ($category in $auditCategories) {
    auditpol /set /category:$category /success:enable /failure:enable
}

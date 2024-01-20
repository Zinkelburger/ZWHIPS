# Enabling process creation (Event ID 4688)
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable

# Enabling process termination (Event ID 4689) - Optional
auditpol /set /subcategory:"Process Termination" /success:enable /failure:enable

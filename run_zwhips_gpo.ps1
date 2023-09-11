# Create and Link GPO
Import-Module GroupPolicy

New-GPO -Name "Run zwhips script" | New-GPLink -Target "OU=YourOU,DC=domain,DC=com" -LinkEnabled Yes

$gpoName = "Run zwhips script"
$gpo = Get-GPO -Name $gpoName
$gpoId = $gpo.Id
$domainName = (Get-ADDomain).DNSRoot
$sysvolPath = "\\{$domainName}\SYSVOL\domain.com\Policies\{$gpoId}\Machine\Scripts\Startup"


# Copy the script to the SYSVOL location for the GPO
Copy-Item -Path "path_to_zwhips.ps1" -Destination "$sysvolPath\zwhips.ps1"

# Append to psscripts.ini (or create it if it doesn't exist)
if (-not (Test-Path "$sysvolPath\psscripts.ini")) {
    New-Item -Path "$sysvolPath\psscripts.ini" -ItemType File
}

Add-Content -Path "$sysvolPath\psscripts.ini" -Value "`0;zwhips.ps1"

# Fetch Machine Names from Active Directory and Force gpupdate
Import-Module ActiveDirectory

$computers = Get-ADComputer -Filter * | ForEach-Object {$_.Name}

foreach ($computer in $computers) {
    # Using PsExec to run gpupdate remotely on each machine
    psexec \\$computer -d gpupdate /force
}

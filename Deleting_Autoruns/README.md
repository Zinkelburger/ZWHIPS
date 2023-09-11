# Scripts related to deleting things that are probably malicious
All scripts log themselves to the console
## delete_registry_run
Deletes the registry keys for run and runOnce

1. delete_registry_startup:

In addition to the Run and RunOnce keys, attackers might use other registry locations for persistence. Consider checking:

    HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
    HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders
    HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
    HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders

## delete_gpo
Deletes all GPO policies

## delete_task_scheduler
Deletes all items in the task scheduler

## delete_startup_folders
Delete items in the startup folders:

    %AppData%\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
    %ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup

## delete_WMI_persistence
Remove WMI event consumer, and filter bindings. Attackers can use WMI for persistence.

## delete_browser_extensions

## delete_logon_scripts
\\YourDomainName\NETLOGON

Local Group Policy Editor:
If you're dealing with a standalone machine (not part of an Active Directory domain) or local policies on a domain-joined computer, logon scripts can be specified using the Local Group Policy Editor.

To see these scripts:

    Run gpedit.msc from the Run dialog or Command Prompt.
    Navigate to: Computer Configuration or User Configuration > Windows Settings > Scripts (Startup/Shutdown or Logon/Logoff).

Run gpmc.msc to open the Group Policy Management Console.
Either create a new GPO or edit an existing one.
Navigate to: Computer Configuration or User Configuration > Policies > Windows Settings > Scripts (Startup/Shutdown or Logon/Logoff).
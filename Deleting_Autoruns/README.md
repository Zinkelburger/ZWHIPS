# Scripts related to deleting things that are probably malicious
All scripts log themselves to the console

## delete_registry_run
Deletes the registry keys in common auto-start locations

```
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
"HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
"HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
"HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
```

## disable_GPO
Disable all GPO policies, besides the ones created by the system user

## enumerate_task_scheduler
People love hiding things in the task scheduler. This is a script to enumerate all the tasks and put them in the 

`Get-ScheduledTask | Format-Table -Property TaskName,TaskPath,State`

For more information:
```pwsh
$outputPath = Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "output.csv"

Get-ScheduledTask | ForEach-Object {
    $info = Get-ScheduledTaskInfo -TaskPath $_.TaskPath -TaskName $_.TaskName
    $actions = $_.Actions

    [PSCustomObject]@{
        'TaskName'     = $_.TaskName
        'TaskPath'     = $_.TaskPath
        'Description'  = $_.Description
        'State'        = $_.State
        'Actions'      = ($actions | ForEach-Object { $_.Execute }) -join '; '
        'Arguments'    = ($actions | ForEach-Object { $_.Arguments }) -join '; '
    }
} | Export-Csv -Path $outputPath -NoTypeInformation
```

## compare_task_scheduler
Powershell to compare two files

$file1Content = Import-Csv -Path 'path\to\file1.csv'
$file2Content = Import-Csv -Path 'path\to\file2.csv'

Compare-Object -ReferenceObject $file1Content -DifferenceObject $file2Content


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
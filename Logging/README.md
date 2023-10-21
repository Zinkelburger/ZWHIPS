### Process Creation / Termination events
Configure auditing on all files/folders. secpol.msc, advanced audit policy configuration, object access

Process creation/termination tracking: Advanced Audit Policy Configuration -> System Audit Policies -> Detailed Tracking.

Via Group Policy (for domain-based setups):

    Open the Group Policy Management Console (GPMC).
    Navigate to the appropriate Group Policy Object (GPO) you wish to modify or create a new one.
    Go to Computer Configuration -> Policies -> Windows Settings -> Advanced Audit Policy Configuration -> Audit Policies -> Detailed Tracking.
    Enable the 'Audit Process Creation' and 'Audit Process Termination'.

    You can also use the auditpol command to set these policies. For example, to enable process creation auditing:

bash

auditpol /set /subcategory:"Process Creation" /success:enabl

And to enable process termination auditing:

bash

auditpol /set /subcategory:"Process Termination" /success:enable

### Viewing the logs
2. Viewing the Process Creation and Termination Events:

    Open the Event Viewer.
    Navigate to Windows Logs -> Security.
    For process creation, look for events with the Event ID 4688.
        The name of the process will be in the event details under "New Process Name".
    For process termination, look for events with the Event ID 4689.
        The name of the terminated process will be in the event details.

### Firewall
Enable logging

To enable firewall logging using PowerShell:

    Open PowerShell as an administrator.

    Use the following command to enable logging for dropped and successful connections for a specific profile (in this example, the Domain profile):

powershell

Set-NetFirewallProfile -Name Domain -LogFileName %systemroot%\system32\LogFiles\Firewall\pfirewall.log -LogMaxSizeKilobytes 16384 -LogAllowed True -LogBlocked True

You can change -Name to Public or Private to set for those profiles. Adjust the LogFileName and LogMaxSizeKilobytes as necessary.

Windows Event Forwarding (WEF)

To review the logs:

    Navigate to the path where the log files are saved (default is %systemroot%\system32\LogFiles\Firewall\pfirewall.log).


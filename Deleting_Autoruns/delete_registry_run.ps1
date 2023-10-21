# Removes registry keys in common malware locations
function Remove-AutorunKey {
        param(
            [string]$Path,
            [string]$Key
        )
    
        try {
            # Fetch key value details
            $keyDetails = Get-ItemProperty -Path $Path -Name $Key
            $keyValue = $keyDetails.$Key
            
            # Print out the key contents
            Write-Host "Contents of ${Key} in ${Path}"
            Write-Host "${Key}: ${keyValue}"
            Write-Host "`n"  # Just for formatting to separate entries
    
            # Remove the specific autorun key
            Remove-ItemProperty -Path $Path -Name $Key
            Write-Host "Deleted $Key from $Path"
            Write-Host "`n"  # Just for formatting to separate entries
        } catch {
            Write-Warning "Error processing $Key in $Path"
        }
    }
    
    # Define autorun registry locations
    $autorunPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
    )
    
    # Iterate over each path and remove keys
    foreach ($path in $autorunPaths) {
        # Check if the path exists before proceeding
        if (Test-Path $path) {
            $keys = Get-ItemProperty -Path $path | 
                    ForEach-Object { $_.PSObject.Properties } |
                    Where-Object { $_.Name -ne "PSPath" -and $_.Name -ne "PSParentPath" -and $_.Name -ne "PSChildName" -and $_.Name -ne "PSDrive" -and $_.Name -ne "PSProvider" } |
                    ForEach-Object { $_.Name }
            foreach ($key in $keys) {
                Remove-AutorunKey -Path $path -Key $key
            }
        }
    }
    
    
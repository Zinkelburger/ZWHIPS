Write-Host "Executing install_npe.ps1..."
& "Antivirus\install_npe.ps1"

# Execute script2.ps1
Write-Host "Executing script2.ps1..."
& "C:\path\to\script2.ps1"

# Start run_microsoft_defender.ps1 as a background job
Write-Host "Starting run_microsoft_defender.ps1 as a background job..."
$runMicrosoftDefender = Start-Job -ScriptBlock {
    & $args[0]
} -ArgumentList "Antivirus\run_microsoft_defender.ps1"

# wait and retrieve results from the defender job
$results = Receive-Job -Job $runMicrosoftDefender -Wait
Write-Host $results

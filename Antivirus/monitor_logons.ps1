# Path to the file where processed events will be stored
$processedEventsFile = "ProcessedEvents.txt"

Add-Type -AssemblyName System.Windows.Forms

# Initialize the file if it does not exist
if (-not (Test-Path $processedEventsFile)) {
    New-Item -ItemType File -Path $processedEventsFile | Out-Null
    $processedEventRecordIDs = @()
} else {
    # Read the processed event record IDs from the file
    $processedEventRecordIDs = Get-Content -Path $processedEventsFile
}

# Loop to check for new events every 10 seconds
while ($true) {
    # Update the time range for the query
    $startTime = (Get-Date).AddHours(-1)
    $endTime = Get-Date

    # Query the Security log for successful logon events
    $slogonevents = Get-WinEvent -FilterHashtable @{
        LogName='Security'
        ID=4624
        StartTime=$startTime
        EndTime=$endTime
    }

    # Iterate through the events and print a detailed summary for specific logon types
    foreach ($e in $slogonevents) {
        if ($e.RecordId -notin $processedEventRecordIDs) {
            $eventData = [xml]$e.ToXml()
            $logonType = $eventData.Event.EventData.Data | Where-Object { $_.Name -eq 'LogonType' } | Select-Object -ExpandProperty '#text'
            $user = $eventData.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' } | Select-Object -ExpandProperty '#text'
            $workstation = $eventData.Event.EventData.Data | Where-Object { $_.Name -eq 'WorkstationName' } | Select-Object -ExpandProperty '#text'
            $ipAddress = $eventData.Event.EventData.Data | Where-Object { $_.Name -eq 'IpAddress' } | Select-Object -ExpandProperty '#text'

            if ($logonType -in (2, 7, 8, 10, 11)) {
                Write-Host "Event ID: $($e.Id)`tTime: $($e.TimeCreated)`tLogon Type: $logonType`tUser: $user`tWorkstation: $workstation`tIP Address: $ipAddress"
                [System.Windows.Forms.MessageBox]::Show("New logon event detected:`nUser: $user", "Logon Notification")
            }

            # Append the processed event record ID to the file
            Add-Content -Path $processedEventsFile -Value $e.RecordId
        }
    }

    # Wait for 10 seconds before checking again
    Start-Sleep -Seconds 10
}

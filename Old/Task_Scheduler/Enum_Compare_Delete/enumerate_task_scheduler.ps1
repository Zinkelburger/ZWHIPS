$outputPath = Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "taskSchedulerOutput.csv"

Get-ScheduledTask | ForEach-Object {
    # $taskInfo = Get-ScheduledTaskInfo -TaskPath $_.TaskPath -TaskName $_.TaskName
    $actions = $_.Actions

    [PSCustomObject]@{
        'TaskName'     = $_.TaskName
        'TaskPath'     = $_.TaskPath
        'Description'  = $_.Description
        # 'State'        = $_.State
        'Actions'      = ($actions | ForEach-Object { $_.Execute }) -join '; '
        'Arguments'    = ($actions | ForEach-Object { $_.Arguments }) -join '; '
    }
} | Export-Csv -Path $outputPath -NoTypeInformation

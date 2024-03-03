# potentially blocking, as it asks for user input if there are more than 5 lines to remove
$DocumentsPath = [Environment]::GetFolderPath("MyDocuments")
$OutFile = Join-Path -Path $DocumentsPath -ChildPath "validTaskScheduler.csv"
Invoke-WebRequest -Uri "https://github.com/Zinkelburger/ZWHIPS/blob/main/Deleting_Autoruns/validTaskScheduler1.csv?plain=1" -OutFile $OutFile

$outputPath = Join-Path -Path $DocumentsPath -ChildPath "taskSchedulerOutput.csv"
$validTaskPath = Join-Path -Path $DocumentsPath -ChildPath "validTaskScheduler.csv"
$linesToRemovePath = Join-Path -Path $DocumentsPath -ChildPath "linesToRemove.csv"

# Gather current task information
Get-ScheduledTask | ForEach-Object {
    $actions = $_.Actions

    [PSCustomObject]@{
        TaskName    = $_.TaskName
        TaskPath    = $_.TaskPath
        Description = $_.Description
        Actions     = ($actions | ForEach-Object { $_.Execute }) -join '; '
        Arguments   = ($actions | ForEach-Object { $_.Arguments }) -join '; '
    }
} | Export-Csv -Path $outputPath -NoTypeInformation

# Import both CSV files
$taskSchedulerOutput = Import-Csv -Path $outputPath
$validTaskScheduler = Import-Csv -Path $validTaskPath

# Compare and get the differences
$diff = Compare-Object -ReferenceObject $taskSchedulerOutput -DifferenceObject $validTaskScheduler -Property TaskName, TaskPath -PassThru |
        Where-Object { $_.SideIndicator -eq '<=' }

# Output the differences
$diff | Export-Csv -Path $linesToRemovePath -NoTypeInformation

# Check the number of tasks to remove
$tasksToRemove = Import-Csv -Path $linesToRemovePath

if ($tasksToRemove.Count -gt 5) {
    Write-Host "There are more than 5 tasks to remove. Please review the file at $linesToRemovePath before continuing."
    Write-Host "Press any key to continue after reviewing..."
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    # Confirm continuation
    $confirmation = Read-Host "Do you want to continue with task removal? (Y/N)"
    if ($confirmation -ne 'Y') {
        Write-Host "Task removal cancelled by user."
        exit
    }
}

# Removing tasks
foreach ($task in $tasksToRemove) {
    $taskName = $task.TaskName
    $taskPath = $task.TaskPath

    try {
        Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false -ErrorAction Stop
        Write-Output "Removed task: $taskPath$taskName"
    } catch {
        Write-Output "Failed to remove or task not found: $taskPath$taskName"
    }
}

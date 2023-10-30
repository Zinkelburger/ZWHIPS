# Define the path for linesToRemove.csv
$linesToRemovePath = Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "linesToRemove.csv"

# Import linesToRemove.csv
$tasksToRemove = Import-Csv -Path $linesToRemovePath

# Iterate over each task and try to remove it
foreach ($task in $tasksToRemove) {
    $taskName = $task.TaskName
    $taskPath = $task.TaskPath

    # Check if the task exists before trying to remove
    if (Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false
        Write-Output "Removed task: $taskPath$taskName"
    } else {
        Write-Output "Task not found: $taskPath$taskName"
    }
}

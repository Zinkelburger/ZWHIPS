# Define the paths
$outputPath = Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "taskSchedulerOutput.csv"
$validTaskPath = Join-Path -Path (Get-Location) -ChildPath "validTaskScheduler.csv"
$linesToRemovePath = Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "linesToRemove.csv"

# Import both CSV files
$taskSchedulerOutput = Import-Csv -Path $outputPath
$validTaskScheduler = Import-Csv -Path $validTaskPath

# Compare and get the differences based on the specified properties
$diff = Compare-Object -ReferenceObject $taskSchedulerOutput -DifferenceObject $validTaskScheduler -Property TaskName, TaskPath -PassThru | Where-Object { $_.SideIndicator -eq '<=' }

# Output the differences to linesToRemove.csv
$diff | Export-Csv -Path $linesToRemovePath -NoTypeInformation

# Define the output path
$outputPath = Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "currentJobs.csv"

# Get all PowerShell jobs
$jobs = Get-Job

# For each job, get all properties and export them to the CSV file
foreach ($job in $jobs) {
    $job | Select-Object * | Export-Csv -Path $outputPath -NoTypeInformation -Append

    # Remove the job after logging its details
    Remove-Job -Job $job
}

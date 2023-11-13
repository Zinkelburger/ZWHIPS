# takes input.csv, makes a powershell script that will recreate it
# Define the input path
$inputPath = Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "input.csv"

# Read the CSV file
$csvContent = Get-Content -Path $inputPath -Raw

# Create the PowerShell script content
$scriptContent = @"
`$text = @'
$csvContent
'@

# Define the output path
`$outputPath = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath 'validTaskScheduler.csv'

# Write the text to the CSV file
`$text | Out-File -FilePath `$outputPath
"@

# Define the output path for the new PowerShell script
$scriptPath = Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "taskSchedulerScript.ps1"

# Write the PowerShell script to a file
$scriptContent | Out-File -FilePath $scriptPath

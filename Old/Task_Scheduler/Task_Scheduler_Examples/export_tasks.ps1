# $exportPath = "$env:UserProfile\Documents\ExportedTasks"
# if(!(Test-Path -Path $exportPath )){
#     New-Item -ItemType directory -Path $exportPath
# }

# Get-ScheduledTask | foreach { 
#     Export-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath | Out-File "$exportPath\$($_.TaskName).xml"
# }

schtasks /query /FO CSV /V > exportedtasks.csv

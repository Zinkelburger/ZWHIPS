# Clear all tasks
Get-ScheduledTask | foreach { 
        Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false
}
# Register new tasks
$importPath = "$env:UserProfile\Documents\ExportedTasks"
if(Test-Path -Path $importPath ){
    Get-ChildItem -Path $exportPath -Filter *.xml | foreach {
        $taskName = $_.BaseName
        Register-ScheduledTask -Xml (Get-Content $_.FullName | Out-String) -TaskName $taskName
    }
}

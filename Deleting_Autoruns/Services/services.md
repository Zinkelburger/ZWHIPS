`Get-Service`

`Get-Service -Name Spooler -DependentServices`

`Get-Service -Name Spooler -RequiredServices`

`Get-Service | Where-Object {$_.Status -eq 'Running'}`

`Get-Service | Where-Object {$_.StartType -eq 'Manual'}`

`Stop-Service -Name spooler`

`Start-Service -Name spooler`

Service's Operation: When a Windows service starts, the operating system loads the executable file into memory. After this point, the running state of the service is independent of the physical file on the disk. Therefore, moving or deleting the executable file won't typically stop or affect the running service.

Service Restart: If the service is stopped and then attempted to be restarted, it will fail to start if the executable file is not in the expected location. This is where moving the file can prevent the service from starting again.

File Locking: In some cases, Windows locks executable files of running services, making it difficult or impossible to move or delete them while the service is active.
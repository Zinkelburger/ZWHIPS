# Manually Disabling Task Scheduler
It is possible that the red team will disable Powershell, in which case the scripts will not work

To disable the Task Scheduler service from the Windows Graphical User Interface (GUI):

## Accessing Services:
Press Win + R on your keyboard to bring up the "Run" dialog box.

Type services.msc and press Enter or click OK. This will open the Services application.

## Locating Task Scheduler:
In the Services application, scroll down and find the service named Task Scheduler.

## Disabling Task Scheduler:
Right-click on Task Scheduler and choose Properties.

In the "General" tab, under the "Startup type" dropdown menu, select Disabled.

If the service is currently running, click the Stop button to stop it immediately.

Click OK to save your changes.
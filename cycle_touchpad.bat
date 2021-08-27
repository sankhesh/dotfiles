REM Script to disable and enable the touchpad driver for wake-after-sleep issues on the Dell
REM Alienware G7 laptop.
REM
REM To run this as a task when the touchpad error occurs:
REM 1. Open Event Viewer and navigate to System log.
REM 2. Right-click on the "MTConfig error" and select "Attach Task to this Event"
REM 3. Set the task to run this program
REM 4. After setting up the task, the properties for the task can be viewed from the Task Scheduler
REM application.
REM 5. Set the property to run this task at the highest privilege so as to run it as administrator.
REM
REM https://www.dell.com/community/XPS/XPS-13-7390-2-in-1-Touchpad-stops-working-after-sleep/m-p/7660402/highlight/true#M66807
REM https://www.dell.com/community/XPS/XPS-13-7390-2-in-1-Touchpad-stops-working-after-sleep/m-p/7660251/highlight/true#M66786

powershell.exe -command "Get-PnpDevice -FriendlyName '*touch pad*'  | Disable-PnpDevice -Confirm:$false"
powershell.exe -command "Get-PnpDevice -FriendlyName '*touch pad*'  | Enable-PnpDevice -Confirm:$false"

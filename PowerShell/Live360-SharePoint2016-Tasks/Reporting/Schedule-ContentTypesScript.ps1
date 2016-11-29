$cred = Get-Credential
$option = New-ScheduledJobOption -RunElevated
$trigger = New-ScheduledTaskTrigger -Daily -At "05:00"
Register-ScheduledJob -Name ContentTypeReporting -Credential $cred -ScriptBlock {D:\SP2013\Scripts\Reports\ContentTypes.ps1} -ScheduledJobOption $option -Trigger $trigger

$cred = Get-Credential
$option = New-ScheduledJobOption -RunElevated
$trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -DaysOfWeek Friday -At "23:30"
Register-ScheduledJob -Name SiteReporting -Credential $cred -ScriptBlock {D:\SP2013\Scripts\Reports\SiteStatistics.ps1} -ScheduledJobOption $option -Trigger $trigger

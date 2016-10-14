$webs = Get-SPWebApplication | Get-SPSite -Limit ALL | Get-SPWeb -Limit ALL
$webs.Count

$web = Get-SPWeb http://intranet/sites/subsitecol

#From Function Files: Get-StorageSpaces
GetWebSizes http://intranet
GetWebSizes $web.Url

$web.Lists.Count

$lists = $web.Lists
foreach($list in $lists){
    Write-Host $list.Title "-" $list.ItemCount
}

$list = $web.Lists["Master Page Gallery"]
$list

$lists = $web.Lists | ? {$_.IsCatalog -eq $false}
$lists | ft Title
$lists = $web.Lists | ? {$_.IsCatalog -eq $false -and $_.IsSiteAssetsLibrary -eq $false -and $_.Hidden -eq $false -and $_.BaseTemplate -ne "WebPageLibrary" -and $_.AllowDeletion -ne $false}
 
$list = $lists | ? {$_.Title -match "Documents"}

#From Function Files: Get-StorageSpaces
$size = GetFolderSize -Folder $list.RootFolder
Write-Host "Size in MB:" ($size/1MB).ToString("#.####")
Write-Host "Size in GB:" ($size/1GB).ToString("#.####")


#Reporting on Growth on a regular schedule

E:\Github\Presentations\PowerShell\FSIG-PowerShellSharePointGettingStarted\HelperScripts\SiteStatistics.ps1

#region schedule script

$cred = Get-Credential "navuba\spadmin"
$option = New-ScheduledJobOption -RunElevated
$trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -DaysOfWeek Friday -At "23:30"
Register-ScheduledJob -Name SiteReporting -Credential $cred -ScriptBlock {E:\Github\Presentations\PowerShell\FSIG-PowerShellSharePointGettingStarted\HelperScripts\SiteStatistics.ps1} -ScheduledJobOption $option -Trigger $trigger

#endregion
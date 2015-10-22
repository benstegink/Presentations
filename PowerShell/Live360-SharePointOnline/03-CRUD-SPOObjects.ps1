. C:\Github\Presentations\PowerShell\Live360-SharePointOnline\FunctionFiles\Load-SPOFunctions.ps1

$creds = Get-Credential
$url = "https://navuba.sharepoint.com/demo"
$adminUrl = "https://navuba-admin.sharepoint.com"

#connect to OfficeDevPnP.PowerShell.Commands
Connect-SPOnline -Url $url -Credentials $creds

#Connect to Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url $adminUrl -Credential $creds

#connect to Microsoft Online/Office 365
Connect-MsolService -Credential $creds

break

Get-Command Add-SPO*
Get-Command Remove-SPO*

###### Add List Item #####
$web = Get-SPOWeb

#create hashtable
$item = @{"Title" = "My Item"}
Add-SPOListItem -List "My List" -Values $item

$list = Get-SPOList "My List"
$fields = Get-SPOListFields -list $list

#task list
$startDate = (Get-Date).Date
$dueDate = (Get-DAte).Date.AddDays(14)
$assignedTo = Get-SPOUid -loginName "ben@navuba.com" -web $web
$assignedTo = Get-SPOUser -LoginName "bryan@navuba.com" -Site https://navuba.sharepoint.com
$task = @{"Title" = "Task 1";"StartDate"=$startDate;"DueDate"=$dueDate;"AssignedTo"=$id;}

break

$task
Add-SPOListItem -List "Task List" -Values $task

#upload document
Get-Help Add-SPOFile -Examples

Add-SPOFile -Path 'C:\DemoFiles\001113 update.doc' -Folder "/Shared Documents"


########## Edit List Item ##########
Get-SPOListItem -List "Documents"
$items = Get-SPOListItem -List "Documents"
$item = $items[2]
$item["Title"]
$item["Title"] = "Temp Title"
$item.Update()
$item.Context.ExecuteQuery()



########## Delete List Item ##########

#Delete List Item
$item.DeleteObject()
$item.Context.ExecuteQuery()
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

########## Working with Site Collections ##########
# The following section contains scripts for
# working with site collections
###################################################

#region sites & webs
#site template codes - http://www.funwithsharepoint.com/sharepoint-2013-site-templates-codes-for-powershell/

#create a new site collection
#Microsoft
New-SPOSite -Url "https://navuba.sharepoint.com/sites/jaxspug" -Owner "ben@navuba.com" -Title "JaxSPUG" -StorageQuota 5 -Template "STS#0"

#delete a site collection
Remove-SPOSite "https://navuba.sharepoint.com/sites/badsite"

#remove it from the recycle bin
Remove-SPODeletedSite "https://navuba.sharepoint.com/sites/badsite"


#create a new web
#DevPnP
$url = "https://navuba.sharepoint.com/sites/jaxspug"
Connect-SPOnline -Url $url -Credentials $creds
New-SPOWeb -url "oct" -Title "October Meeting" -InheritNavigation -Template "STS#1"

#delete a web
#DevPnP - not working
$url = "https://navuba.sharepoint.com/sites/badsite"
Connect-SPOnline -Url $url -Credentials $creds
Remove-SPOWeb -Url "subweb"

#combo of DevPnP and CSOM
$url = "https://navuba.sharepoint.com/sites/badsite/subweb"
Connect-SPOnline -Url $url -Credentials $creds
$web = Get-SPOWeb
$web.Context.web.DeleteObject()
$web.Context.ExecuteQuery()

#endregion

#region Lists

#create a list
#DevPnP
$url = "https://navuba.sharepoint.com/sites/JaxSPUG/Oct"
Connect-SPOnline -Url $url -Credentials $creds
$web = Get-SPOWeb
New-SPOList -Title "Minutes" -Template DocumentLibrary -Url "Minutes"
New-SPOList -Title "Meeting Minutes" -Template DocumentLibrary -Url "MeetingMinutes"

#remove a list
#DevPnP
$url = "https://navuba.sharepoint.com/sites/jaxspug/oct"
Connect-SPOnline -Url $url -Credentials $creds
Remove-SPOList -Identity "Minutes"

#endregion

########## Workign with List Items ##########
# The following section contains scripts
# for working with list items
#############################################

#region List Items

###### Add List Item #####
$web = Get-SPOWeb

#create hashtable
$item = @{"Title" = "My Item"}
Add-SPOListItem -List "My List" -Values $item

$list = Get-SPOList "My List"

#Get-SPOListFields in a custom function
$fields = Get-SPOListFields -list $list

#task list
$startDate = (Get-Date).Date
$dueDate = (Get-DAte).Date.AddDays(14)
#Get-SPOUid is a custom function
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

#endregion
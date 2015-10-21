. C:\Github\Presentations\PowerShell\Live360-SharePointOnline\FunctionFiles\Load-SPOFunctions.ps1

$creds = Get-Credential
$url = "https://navuba.sharepoint.com"
$adminUrl = "https://navuba-admin.sharepoint.com"

#connect to OfficeDevPnP.PowerShell.Commands
Connect-SPOnline -Url $url -Credentials $creds

#Connect to Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url $adminUrl -Credential $creds

#connect to Microsoft Online/Office 365
Connect-MsolService -Credential $creds

break

#region Get Basic Info

#Get Office Online Info
Write-Host "Get Office Online Info" -ForegroundColor Green
Get-MsolCompanyInformation

#Get SharePoint Online Info
Write-Host "Get SharePoint Online Info" -ForegroundColor Green
Get-SPOTenant

#endregion

break

########### Web Applications ##########
#
# In SharePoint online, there is no concept of web applications
# the higest "container" is a site collection
#
#######################################


########### Site Collections ##########
#
# In SharePoint online, there is no concept of web applications
# the higest "container" is a site collection
#
#######################################

#region Site Collections

#get all site collections
#Can only really get a list of all site collections by using Get-SPSite (Microsoft Version)
Microsoft.Online.SharePoint.PowerShell\Get-SPOSite | ft Url,Status,LocaleId,StorageQuota
$sites = Microsoft.Online.SharePoint.PowerShell\Get-SPOSite

break

#only gets the site collection you're connected to
OfficeDevPnP.PowerShell.Commands\Get-SPOSite
$site = OfficeDevPnP.PowerShell.Commands\Get-SPOSite

$site2 = $sites | ? {$_.Url -eq "https://navuba.sharepoint.com/"}

#site and $site2 end up as two different objects
Write-Host "Microsoft.Online.SharePoint.PowerShell" -ForegroundColor Green
$site

break

Write-Host "OfficeDevPnP.PowerShell.Commands" -ForegroundColor Green
$site2

break

Write-Host "Begin Site Collections" -ForegroundColor Green



#endregion

break


########## Web #########
#Get the Root Web
$url = "https://navuba.sharepoint.com"
Connect-SPOnline -Url $url -Credentials $creds
$site = OfficeDevPnP.PowerShell.Commands\Get-SPOSite

#Site Object is from DevPnP Module Get-SPOSite
$rootWeb = $site.RootWeb
$rootWeb

break

$rootWeb = Get-SPOWeb
$rootWeb


#Get the root web properties
$rootweb.AllProperties
$propBag = Get-SPOPropertyBag -Web $rootWeb
$propBag

#Get a single property from the property bag
($propBag | ? {$_.Key -eq "__pageslistname"}).Key
($propBag | ? {$_.Key -eq "__pageslistname"}).Value

$PagesListName = ($propBag | ? {$_.Key -eq "__pageslistname"}).Value


#Sub Webs
#DevPnP Commands
$subwebs = Get-SPOSubWebs #Get the subwebs for only the current connected web
$subwebs


#List
Get-SPOList
Get-SPOList -Identity "Documents"

#Get the documents list in each subsweb and the number of documents in it
foreach($web in $subwebs){
    $l = Get-SPOList -Identity Documents -Web $web
    $l.ItemCount
}

#List Item
Get-SPOListItem
foreach($i in $items2){Write-Host $i.FieldValues.File_x0020_Type "-" $i.FieldValues.FileLeafRef}
$i = Get-SPOListItem -List Documents -Id 6
$i.FieldValues
$i.FieldValues.Created
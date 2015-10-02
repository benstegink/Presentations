#Work with the get
Get-SPWeb
Get-SPWeb -?
Get-SPWeb http://intranet/sites/TeamSite1
$web = Get-SPWeb http://intranet/sites/TeamSite1
$web.Title
$web.Title = "My Super Awesome Team Site"
#didn't update
$web.Update()

#what else can we find...
$web.Properties
$web.AllProperties

#Add our own Property
$web.AllProperties["Version"] = "2.0.0"
$web.Update()
$web.AllProperties

#Lists?
$web.Lists | ft Title
$web.Lists[0]
$web.Lists | ft Title, Fields

$list = $web.Lists[0]
$list.Title
$list = $web.Lists | ? {$_.Title -eq "Style Library"}
$list.Title

#list items
$list.ItemCount
$list.Items
$list.Items | ft Name
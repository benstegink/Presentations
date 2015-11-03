#######
#
# pipe = |
# foreach-object = foreach = %
# where-object = where = ?
#
#######

#region Aliases
#alias for cmdlets
alias where
alias foreach
alias ?

alias for exe
alias ise

#new alias
New-Alias -Name np -Value notepad.exe
New-Alias -name spwa -Value Get-SPWebApplication

#endregion

Start-Transcript -Path e:\transcript.txt
Stop-Transcript

#region Getting Started with SharePoint

Add-PSSnapin Microsoft.SharePoint.PowerShell

Get-SPWebApplication | % {$_.Url}

#endregion

#region Web Apps, Sites, Webs
$wa = Get-SPWebApplication http://intranet
$wa
$wa.Sites

$site = Get-SPSite http://intranet

$web = Get-SPWeb http://intranet


#region multiples
$wa = Get-SPWebApplication
$wa

$sites = $wa | Get-SPSite -Limit ALL
$sites

$webs = $sites | Get-SPWeb -Limit ALL
$webs


# -or-

$webs = Get-SPWebApplication | Get-SPSite -Limit ALL | Get-SPWeb -Limit ALL

#just a single web application
$webs = Get-SPWebApplication -Identity http://intranet | Get-SPSite -Limit ALL | Get-SPWeb -Limit ALL
#endregion

#region create sites and webs
Get-SPWebTemplate
Get-SPWebTemplate | where {$_.CompatibilityLevel -eq "15"}
Get-SPWebTemplate | where {$_.CompatibilityLevel -eq "15" -and $_.Title -match "Team"}

$siteTemplate = Get-SPWebTemplate | ? {$_.Title -eq "Team Site" -and $_.CompatibilityLevel -eq "15"}

#site collection
#Splatting - http://trevorsullivan.net/2015/08/11/powershell-splatting-overview/
$siteColProperties = @{
    Url = 'http://intranet/sites/splatting';
    OwnerAlias='navuba\spadmin';
    SecondaryOwnerAlias = 'navuba\bstegink';
    Template = $siteTemplate;
    Name = 'Splatting Team Site';
    Description = 'This is a site created using PowerShell Splatting';
}

Write-Host -Object ('New Site Collection Created at {0} using the template {1}. The Site collection owners are {2} and {3}' -f $siteColProperties.Url,$siteColProperties.Template.Title,$siteColProperties.OwnerAlias,$siteColProperties.SecondaryOwnerAlias)

New-SPSite @siteColProperties

#web
New-SPWeb -Url "http://intranet/sites/splatting/subsite" -Template $siteTemplate


#Deleted Site Collections
Get-SPDeletedSite
Remove-SPDeletedSite

#endregion

#endregion

#region lists and libraries
$web = Get-SPWeb http://intranet/sites/subsitecol
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

#Lists
$web.Lists
$web.Lists | ft Title
$web.Lists[0]
or
$web.Lists["Documents"] | ft Title
$web.Lists | ft Title, Fields

$list = $web.Lists[0]
$list.Title
$list = $web.Lists | ? {$_.Title -eq "Style Library"}
$list.Title
$list = $web.Lists["Documents"]
$list.Title

#list items
$list.ItemCount
$list.Items
$list.Items | ft Name


#deleting list items, the process is similar for lists, webs and site collections
$item = $list.Items[0]
$item.Delete() #completely deletes the item
$item = $list.Items[1]
$item.Recycle() #moves the item to the recycle bin



#endregion

#region solutions and features

#Features and Solutions
Get-SPFeature
Get-SPFeature -url http://intranet

Get-Command *-SPFeature


Get-SPSolution

Get-Command *-SPSolution


#Download All Solutions for Backup/DR
#Saves all .WSP Files to the directory specified below
$wspPath = "C:\SharePointSolutions"
New-Item $wspPath -type directory
(Get-SPFarm).Solutions | ForEach-Object{$var = $wspPath + "\" + $_.Name; $_.SolutionFile.SaveAs($var)}

#endregion 

#region security and permissions

#Permissions
$web = Get-SPWeb http://intranet
$web.Groups | ft Name, Roles
$web.Roles | ft Name
$group = $web.Groups | ? {$_.Name -eq "Intranet Members"}
$role = $web.Roles[2]

#What Permissions can we assing??
[System.Enum]::GetNames("Microsoft.SharePoint.SPBasePermissions")

#What do some levels already have?
$web = Get-SPWeb http://intranet/sites/subsitecol
$web.RoleDefinitions["Edit"].BasePermissions


#Add/Create New Permission Level

#Make sure the permission level doesn't already exists
if($web.RoleDefinitions["Site Owner"] -eq $null)
{
    # Role Definition named "Site Owner" does not yet exist
    $RoleDefinition = New-Object Microsoft.SharePoint.SPRoleDefinition
    $RoleDefinition.Name = "Site Owner"
    $RoleDefinition.Description = "Permission Level to be Used for the Site Owners Group"
 
    #Below still allows user to create subsites
    $RoleDefinition.BasePermissions = "ViewListItems, AddListItems, EditListItems, DeleteListItems, OpenItems, ViewVersions, DeleteVersions, CancelCheckout, ManagePersonalViews, ViewFormPages, AnonymousSearchAccessList, Open, ViewPages, AddAndCustomizePages, ViewUsageData, ManageSubwebs, BrowseDirectories, BrowseUserInfo, AddDelPrivateWebParts, UpdatePersonalWebParts, AnonymousSearchAccessWebLists, UseClientIntegration, UseRemoteAPIs, ManageAlerts ,CreateAlerts, EditMyUserInfo, EnumeratePermissions"
    $web.RoleDefinitions.Add($RoleDefinition)
}
 
#Display the properties for our new Permission level
$web.RoleDefinitions["Site Owner"] | Out-Host


#Create a new SharePoint Group
$web = Get-SPWeb http://intranet/sites/subsitecol
#$web.SiteGroups.Add()

#Grante Permissions to the Group
$web.SiteGroups.Add(($web.Title + " Site Owners"),$web.Site.Owner,$web.Site.Owner,"Site Owners Group")
$ownerGroup = $web.SiteGroups[($web.Title + " Site Owners")]
$ownerGroupAssignment = new-object Microsoft.SharePoint.SPRoleAssignment($ownerGroup)
$OwnerRoleDef = $web.RoleDefinitions["Site Owner"]
$ownerGroupAssignment.RoleDefinitionBindings.Add($OwnerRoleDef)
$web.RoleAssignments.Add($ownerGroupAssignment)
$web.Update()


#endregion



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
Write-Host "OfficeDevPnP.PowerShell.Commands" -ForegroundColor Green
$site2

break

Write-Host "Begin Site Collections" -ForegroundColor Green

foreach($site in $sites){
    if($site.Url -notmatch "http://www"){
        Connect-SPOnline -Url $site.Url -Credentials $creds
        $DevPnPSite = OfficeDevPnP.PowerShell.Commands\Get-SPOSite
        #Uses CSOM
        $DevPnPSite.Context.Load($DevPnPSite)
        $DevPnPSite.Context.ExecuteQuery()
        #End User CSOM
        $obj = New-Object PSObject
        $obj | Add-Member NoteProperty URL $DevPnPSite.Url
        Write-Host $DevPnPSite
    }

}

#endregion

break



########## Web #########
#Get the Root Web

#Get the root web properties

#Sub Webs

#List

#List Item
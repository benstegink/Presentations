. C:\Github\Presentations\PowerShell\Live360-SharePointOnline\FunctionFiles\Load-SPOFunctions.ps1

#initial array of site collections with info about them
$sites = Microsoft.Online.SharePoint.PowerShell\Get-SPOSite

$siteColl = @()
foreach($tmpSite in $sites){
    if($tmpSite.Url -notmatch "http://www"){
        Connect-SPOnline -Url $tmpSite.Url -Credentials $creds
        $DevPnPSite = OfficeDevPnP.PowerShell.Commands\Get-SPOSite
        #Uses CSOM
        $DevPnPSite.Context.Load($DevPnPSite)
        $DevPnPSite.Context.ExecuteQuery()
        #End User CSOM

        #User Custom functino to create a custom site collection object
        $usage = (Get-SPOProperty -ClientObject $DevPnPSite -Property Usage).Storage/1MB #Get-SPOProperty is a DevPnP Function

        #Create Site Object is a custom fuction
        $objSite = Create-SiteObject -Url $DevPnPSite.Url -AllowSPDesigner $DevPnPSite.AllowDesigner -Storage $usage.ToString("#.##")
        #add the object to the array
        $siteColl += $objSite
    }

}

#Output the entire list of site collection objects
$siteColl | ft Url,Storage


#Custom Recursive Function to get all webs
#Get-SubWebs is a custom function
$webs = Get-SubWebs -url "https://navuba.sharepoint.com" -creds $creds
$webs


#Features
$url = "https://navuba.sharepoint.com"
Connect-SPOnline -Url $url -Credentials $creds
$site = OfficeDevPnP.PowerShell.Commands\Get-SPOSite
$web = Get-SPOWeb
$ctx = $web.Context

$webFeatures = $web.Features
$siteFeatures = $site.Features
$ctx.Load($webFeatures)
$ctx.Load($siteFeatures)
$ctx.ExecuteQuery()
$webFeatures
$siteFeatures

#web feature
foreach($f in $webFeatures){
    $ctx.Load($f);
    $ctx.ExecuteQuery();
    if($f.DefinitionId -eq "94c94ca6-b32f-4da9-a9e3-1f3d343d7ecb"){
        $f
    }
}

#site feature
foreach($f in $siteFeatures){
    $ctx.Load($f);
    $ctx.ExecuteQuery();
    if($f.DefinitionId -eq "f6924d36-2fa8-4f0b-b16d-06b7250180fa"){
        $f
    }
}

#Activate a feature
Add-SPOFeature -context $ctx -featureID "f6924d36-2fa8-4f0b-b16d-06b7250180fa" -scope "Site"
Add-SPOFeature -context $ctx -featureID "94c94ca6-b32f-4da9-a9e3-1f3d343d7ecb" -scope "Web"

#Get properties of an object using Gary LaPointe's function
$ctx = $web.Context
Load-CSOMProperties -object $web -propertyNames @("Title", "Url", "AllProperties") -executeQuery
$web | select Title, Url, AllProperties


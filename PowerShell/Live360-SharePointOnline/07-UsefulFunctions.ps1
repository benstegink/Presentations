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
        $objSite = Create-SiteObject -Url $DevPnPSite.Url -AllowSPDesigner $DevPnPSite.AllowDesigner -Storage $usage.ToString("#.##")
        #add the object to the array
        $siteColl += $objSite
    }

}

#Output the entire list of site collection objects
$siteColl | ft Url,Storage


#Custom Recursive Function to get all webs
$webs = Get-SubWebs -url "https://navuba.sharepoint.com" -creds $creds
$webs
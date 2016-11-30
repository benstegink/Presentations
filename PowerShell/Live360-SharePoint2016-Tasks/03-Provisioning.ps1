$weburl = "http://sp16-intranet"
$web = Get-SPWeb $weburl
$list = $web.Lists["Site Requests"]
$pending = $list.Views["PendingRequests"]
$items = $list.GetItems($pending)
foreach($item in $items){
    $item["ProvisioningStatus"] = "Provisioning"
    $item.Update()
    #$item = $items | ? {$_.Id -eq $item.Id}
    $siteId = $item.ID
    $siteTitle = $item.Title
    $siteType = $item["TypeOfSite"]
    $dept = $item["Department"]
    $siteOwner = $item["SiteOwner"]

    if($siteType -eq "Team Site"){
        $manPath = "/team/T_"
    }
    elseif($siteType -eq "Project Site"){
        $manPath = "/project/P_"
    }
    $url = ($weburl + $manPath + $siteId)

    try{
        #Create the New Site
        $siteOwner = $siteOwner.Substring($siteOwner.IndexOf('#')+1,$siteOwner.Length - $siteOwner.IndexOf('#')-1)
        $siteOwnerAlias = Get-SPUser -Web $weburl | ? {$_.DisplayName -eq $siteOwner}
        $newsite = New-SPSite -Url $url -Name $siteTitle -OwnerAlias $siteOwnerAlias.UserLogin -Template STS#0 -CreateFromSiteMaster

        #Add Site Properties
        $web = $newsite.RootWeb
        $web.AllProperties["SiteType"] = $siteType
        $web.AllProperties["Department"] = $dept
        $web.AllProperties["SiteOwner"] = $siteOwner
        $web.AllProperties["SiteOwnerEmail"] = $siteOwnerAlias.Email
        $web.Update()

        #Update Request
        $item["SiteUrl"] = $newsite.Url
        $item["ProvisioningStatus"] = "Complete"
        $item.Update()


        #Provisioning Functions

        #Set the Site Owner Permissions
    	Create-SharePointPermissionLevel "Site Owner" $url
        Create-SharePointGroup -groupname "Site Owner" -url $url -permissionLevel "Site Owner" -farmadmin $farmadmin
        Add-GroupToSecurityQL $url ($web.Title + " Site Owner")

        Add-SiteCollectionAdmin -url $url -user $requestor

        #Activate Features
        Activate-TeamSiteFeatures -url $url

        #Add Content Types
        if($sitetype -eq "IS"){
            Add-ContentTypes -url $url -listname "Documents" -contenttypes "IS" -update $true           
        }
        if($sitetype -eq "HR"){
            Add-ContentTypes -url $url -listname "Documents" -contenttypes "HR" -update $true
        }

        #Set Field Defaults
        Set-FieldDefaults -url $url -listName "Documents"

    }
    catch{
        $item["ProvisioningStatus"] = "Error"
        $item.Update()
    }
}

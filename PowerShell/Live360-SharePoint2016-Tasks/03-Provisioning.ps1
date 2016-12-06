$weburl = "http://sp16-intranet"
$web = Get-SPWeb $weburl
$list = $web.Lists["Site Requests"]
$pending = $list.Views["PendingRequests"]
$items = $list.GetItems($pending)
$farmadm = "navuba\spadmin"

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
        $site = Get-SPSite $url -ErrorAction SilentlyContinue
        if($site -eq $null){
            $newsite = New-SPSite -Url $url -Name $siteTitle -OwnerAlias $siteOwnerAlias.UserLogin -Template STS#0 -CreateFromSiteMaster
        }

        #Add Site Properties
        $web = $newsite.RootWeb
        $web.AllProperties["SiteType"] = $siteType
        $web.AllProperties["Department"] = $dept
        $web.AllProperties["SiteOwner"] = $siteOwner
        $web.AllProperties["SiteOwnerEmail"] = $siteOwnerAlias.Email
        $web.Update()


        #Provisioning Functions

        #Set the Site Owner Permissions
    	Create-SharePointPermissionLevel "Site Owner" $url
        Create-SharePointGroup -groupname "Site Owner" -url $url -permissionLevel "Site Owner" -groupOwner $farmadm -groupDescription "Site Owners Group"
        Create-SharePointGroup -groupname "Contributors" -url $url -permissionLevel "Contribute" -groupOwner ($web.Title + " " + "Site Owner") -groupDescription "Site Contributors Group"
        Add-GroupToSecurityQL $url ($web.Title + " Site Owner")

        Add-SiteCollectionAdmin -url $url -user $siteOwner

        #Activate Features
        Activate-TeamSiteFeatures -url $url

        ##### Configure Document Libraryes #####

        #Set Library Type
        Set-LibraryType -url $url -libName "Documents" -libraryType "Shared Documents"

        #Add Content Types
        if($sitetype -eq "Team Site"){
            if($dept -eq "Information Technology"){
                Add-ContentTypes -url $url -listname "Documents" -contenttypes "IS" -update $true
            }
            elseif($dept -eq "Human Resources")
            {
                $lists = $web.Lists
                $libTemplate  = [Microsoft.SharePoint.SPListTemplateType]::DocumentLibrary
                $lists.Add("Confidential","Confidential Documents",$libTemplate)
                $web = Get-SPWeb $url
                $lib = $web.Lists["Confidential"]
                $lib.ContentTypesEnabled = $true
                $lib.Update()

                Set-LibraryType -url $url -libName "Confidential" -libraryType "Confidential"

                Add-ContentTypes -url $url -listname "Documents" -contenttypes "HR" -update $true
                Add-ContentTypes -url $url -listname "Confidential" -contenttypes "HR_Con" -update $true
            }           
        }
        elseif($sitetype -eq "Project Site"){
            Add-ContentTypes -url $url -listname "Documents" -contenttypes "Project" -update $true
        }

        #Set Field Defaults
        Set-FieldDefaults -url $url -listName "Documents"

        #Update Request
        $item["SiteUrl"] = $newsite.Url
        $item["ProvisioningStatus"] = "Complete"
        $item.Update()

    }
    catch{
        $item["AdditionalInfo"] = $_.Exception.Message
        $item["ProvisioningStatus"] = "Error"
        $item.Update()
    }
}

#**********Functions for Provisioning Sites**********

#Create Permission Level
function Create-SharePointPermissionLevel([string]$permLevel,$url){
    $web = Get-SPWeb $url
    if($permLevel -eq "Site Owner"){
        if($web.RoleDefinitions["Site Owner"] -eq $null)
        {
            # Role Definition named "Site Owner" does not exist
            $RoleDefinition = New-Object Microsoft.SharePoint.SPRoleDefinition
            $RoleDefinition.Name = "Site Owner"
            $RoleDefinition.Description = "Permission Level to be Used for the Site Owners Group"
 
            #What Permissions can we assign?? Run: [System.Enum]::GetNames("Microsoft.SharePoint.SPBasePermissions")
            $RoleDefinition.BasePermissions = "ViewListItems, AddListItems, EditListItems, DeleteListItems, OpenItems, ViewVersions, DeleteVersions, CancelCheckout, ManagePersonalViews, ViewFormPages, AnonymousSearchAccessList, Open, ViewPages, AddAndCustomizePages, ViewUsageData, BrowseDirectories, BrowseUserInfo, AddDelPrivateWebParts, UpdatePersonalWebParts, AnonymousSearchAccessWebLists, UseClientIntegration, UseRemoteAPIs, ManageAlerts ,CreateAlerts, EditMyUserInfo, EnumeratePermissions, ManagePermissions"
            $web.RoleDefinitions.Add($RoleDefinition)
        }
    }
    elseif($permLevel -eq "IS Admin"){
        if($web.RoleDefinitions["IS Admin"] -eq $null){
            #IS Admin Role Definition named IS Admin does not exist
            $RoleDefinition = New-Object Microsoft.SharePoint.SPRoleDefinition
            $RoleDefinition.Name = "IS Admin"
            $RoleDefinition.Description = "Permission Level to be Used for the IS Admin Group"
        }
    }
    elseif($permLevel -eq "Manage Lists"){
        #1.07 - to be used in tasks lists that require this to add to timeline
        if($web.RoleDefinitions["Manage Lists"] -eq $null)
        {
            # Role Definition named "Manage Lists" does not exist
            $RoleDefinition = New-Object Microsoft.SharePoint.SPRoleDefinition
            $RoleDefinition.Name = "Manage Lists"
            $RoleDefinition.Description = "This permission level has only the Manage Lists permission, and is intended to be added as needed to custom lists that require this permission to function."
 
            #What Permissions can we assign? Run: [System.Enum]::GetNames("Microsoft.SharePoint.SPBasePermissions")
            $RoleDefinition.BasePermissions = "ManageLists"
            $web.RoleDefinitions.Add($RoleDefinition)
        }
    }
    $web.Dispose()
}

#Update SharePoint Group Onwer
function Update-SharePointGroupOwner($groupname,$groupowner,$url){
    $web = Get-SPWeb $url
    #Set the Group Owner
    if($groupname -match "IS Admin"){
        $groupOwner = Get-SPUser -Web $web.Url | ? {$_.UserLogin -match $farmadmin};
    }
    elseif($groupname -match "Site Owner"){
        $groupOwner = $web.Groups | ? {$_.Name -match "IS Admin"}
    }
    else{
        $groupOwner = $web.Groups | ? {$_.Name -eq ($web.Title + " Site Owner")};
        $groupname = ($web.Title + " " + $groupname)
    }
    $group = $web.Groups[$groupname]
    $group.Owner = $groupOwner
    $group.Update()
    $web.Dispose()
}


#Create a SharePoint Group
function Create-SharePointGroup($groupname,$url,$permissionLevel,$farmadmin){
    $web = Get-SPWeb $url
    $gname = ($web.Title + " " + $groupname)

    $groupOwner = Get-SPUser -Web $web.Url | ? {$_.UserLogin -match $farmadmin};

    #Create SharePoint Group
    $sg = $web.SiteGroups[$gname]
    if($sg -eq $null){
        $web.SiteGroups.Add($gname,$groupOwner,$null,"Site Owners Group")
    }
    #Grant Permissions to the Group
    if($permissionLevel -ne $null -and $permissionLevel -ne ""){
        $SPGroup = $web.SiteGroups[$gname]
	    if($groupname -ne "IS Admin"){
		    $SPGroup.OnlyAllowMembersViewMembership = $false
		    $SPGroup.Update()
	    }
        $checkForPerms = $web.RoleAssignments | ? {$_.Member -eq $SPGroup.Name}
        $SPRoleDef = $web.RoleDefinitions[$permissionLevel]
        if($checkForPerms -ne $null){
            $SPGroupAssignment = $web.RoleAssignments.GetAssignmentByPrincipal($SPGroup)
            foreach($roleDef in $SPGroupAssignment.RoleDefinitionBindings){
                if($roleDef.Name -ne "Limited Access"){
                    $SPGroupAssignment.RoleDefinitionBindings.Remove($roleDef)
                }
            }
            $SPGroupAssignment.update()
        }
        else{
            $SPGroupAssignment = New-Object Microsoft.SharePoint.SPRoleAssignment($SPGroup)
        }
        $SPGroupAssignment.RoleDefinitionBindings.Add($SPRoleDef)
        $web.RoleAssignments.Add($SPGroupAssignment)
    }
    #Set Site Owner
    if($groupname -match "Site Owner"){
        $SPGroup = $web.SiteGroups[$gname]
        $web.AssociatedOwnerGroup = $SPGroup
    }
    $web.Update()
    $web.Dispose()
}


function Add-SiteCollectionAdmin($url, $user){
    $web = Get-SPWeb $url
    $user = $web.EnsureUser($user)
    $user.IsSiteAdmin = $true
    $user.Update()
    $web.Dispose()
}

#Enable Features on the Team Site
function Activate-TeamSiteFeatures($url){
    $web = Get-SPWeb $url
    #**********Enable Site Features**********
    #Enable Standard Site Collection Feature
    #Enable-SPFeature -Identity "b21b090c-c796-4b0f-ac0f-7ef1659c20ae" -Url $web.Url
    $baseSite = Get-SPFeature | ? {$_.DisplayName -eq "BaseSite" -and $_.CompatibilityLevel -eq "15"}
    $siteFeature = $web.Site.Features | ? {$_.DefinitionId -eq $baseSite.Id}
    if($siteFeature -eq $null){
        Enable-SPFeature -Identity $baseSite.Id -Url $web.Url
    }
    
    #Enable Enterprise Site Collection Feature
    #Enable-SPFeature -Identity "8581A8A7-CF16-4770-AC54-260265DDB0B2" -Url $web.Url
    $premiumSite = Get-SPFeature | ? {$_.DisplayName -eq "PremiumSite" -and $_.CompatibilityLevel -eq "15"}
    $siteFeature = $web.Site.Features | ? {$_.DefinitionId -eq $premiumSite.Id}
    if($siteFeature -eq $null){
        Enable-SPFeature -Identity $premiumSite.Id -Url $web.Url
    }

    #Enable Standard Site FEature
    #Enable-SPFeature -Identity "99fe402e-89a0-45aa-9163-85342e865dc8" -Url $web.Url
    $baseWeb = Get-SPFeature | ? {$_.DisplayName -eq "BaseWeb" -and $_.CompatibilityLevel -eq "15"}
    $siteFeature = $web.Features | ? {$_.DefinitionId -eq $baseWeb.Id}
    if($siteFeature -eq $null){
        Enable-SPFeature -Identity $baseWeb.Id -Url $web.Url
    }

    #Enable Enterprise Site Feature
    #Enable-SPFeature -Identity "0806d127-06e6-447a-980e-2e90b03101b8" -Url $web.Url
    $premiumWeb = Get-SPFeature | ? {$_.DisplayName -eq "PremiumWeb" -and $_.CompatibilityLevel -eq "15"}
    $siteFeature = $web.Features | ? {$_.DefinitionId -eq $premiumWeb.Id}
    if($siteFeature -eq $null){
        Enable-SPFeature -Identity $premiumWeb.Id -Url $web.Url
    }

    #Open in Client Application by Default
    $openInClient = Get-SPFeature | ? {$_.DisplayName -eq "OpenInClient" -and $_.CompatibilityLevel -eq "15"}
    $siteFeature = $web.Site.Features | ? {$_.DefinitionId -eq $openInClient.Id}
    if($siteFeature -eq $null){
        Enable-SPFeature -Identity $openInClient.Id -Url $web.Url
    }

    #Enable Document ID Feature
    $docID = Get-SPFeature | ? {$_.DisplayName -eq "DocID" -and $_.CompatibilityLevel -eq "15"}
    $siteFeature = $web.Site.Features | ? {$_.DefinitionId -eq $docID.Id}
    if($siteFeature -eq $null){
        Enable-SPFeature -Identity $docID.Id -Url $web.Url
    }

    #Enable Metadata Navigation and Filtering Feature
    $metadataNav = Get-SPFeature | ? {$_.DisplayName -eq "MetaDataNav" -and $_.CompatibilityLevel -eq "15"}
    $webFeature = $web.Features | ? {$_.DefinitionId -eq $metadataNav.Id}
    if($webFeature -eq $null){
        Enable-SPFeature -Identity $metadataNav.Id -Url $web.Url
    }
    $web.Dispose()
}

function Add-GroupToSecurityQL($url,$groupname){
    $web = Get-SPWeb $url
    $group = $web.SiteGroups[$groupname]
    $web.AssociatedGroups.Add($group)
    $web.Update()
    $web.Dispose()
}



function Create-SearchNavigation($url,$sitetype){
    $web = Get-SPWeb $url
    $searchNav = $web.Navigation.SearchNav
    #Start Create Search All Content
    $allContent = $searchNav | ? {$_.Title -eq "All Content"}
    if($allContent -eq $null -or $allContent -eq ""){
        $allContent = New-Object Microsoft.SharePoint.Navigation.SPNavigationNode("All Content",($web.Site.WebApplication.Url.TrimEnd("/") + "/searchcenter/pages/results.aspx"),$true)
        $searchNav.AddAsFirst($allContent)
    }
    else{
        $allContent.Title = "All Content"
        $allContent.Url = ($web.Site.WebApplication.Url.TrimEnd("/") + "/searchcenter/pages/results.aspx")
        $allContent.Update()
    }
    #End Create Search All Content
    if($sitetype -eq "IS"){
        #Start Create IS Search
        $isContent = $searchNav | ? {$_.Title -eq "IS Content"}
        if($isContent -eq $null -or $isContent -eq ""){
            $isContent = New-Object Microsoft.SharePoint.Navigation.SPNavigationNode("IS Content",($web.Site.WebApplication.Url.TrimEnd("/") + "/searchcenter/pages/isresults.aspx"),$true)
            $searchNav.AddAsLast($isContent)
        }
        else{
            $isContent.Title = "IS Content"
            $isContent.Url = ($web.Site.WebApplication.Url.TrimEnd("/") + "/searchcenter/pages/isresults.aspx")
            $isContent.Update()
        }
        #End Create IS Search
    }
    elseif($sitetype -eq "HR"){
        #Start Create HR Search
        $hrContent = $searchNav | ? {$_.Title -eq "HR Content"}
        if($hrContent -eq $null -or $hrContent -eq ""){
            $hrContent = New-Object Microsoft.SharePoint.Navigation.SPNavigationNode("HR Content",($web.Site.WebApplication.Url.TrimEnd("/") + "/searchcenter/pages/hrresults.aspx"),$true)
            $searchNav.AddAsLast($hrContent)
        }
        else{
            $hrContent.Title = "HR Content"
            $hrContent.Url = ($web.Site.WebApplication.Url.TrimEnd("/") + "/searchcenter/pages/hrresults.aspx")
            $hrContent.Update()
        }
        #End Create HR Content
    }
    $web.Dispose()
}

function Set-LibraryType($url,$libName,$libraryType){
    $web = Get-SPWeb $url
    $list = $web.Lists[$libName] 
    $root = $list.RootFolder
    if($root.Properties["LibraryType"] -eq $null){
        $root.AddProperty("LibraryType", $libraryType)
        $root.Update()
    }
    else{
        $root.Properties["LibraryType"] = $libraryType
        $root.Update()
    }
    $web.dispose()
}


function Set-FieldDefaults($url,$listName){
    $web = Get-SPWeb $url
    $lists = $web.Lists
    #Segment Default

    #Managed Meta Data Defaults
    $list = $lists[$listName]
    $DocDefault = New-Object -TypeName Microsoft.Office.DocumentManagement.MetadataDefaults $list
    $fieldDocType = $null
    $fieldDocType = $list.Fields["Document Type"]
    $DocTypeName = $web.AllProperties["Sitetype"]


    if($fieldDocType -ne $null -and $DocTypeName -ne $null){
        [void] $DocDefault.SetFieldDefault($list.RootFolder,$fieldDocType.InternalName,$DocTypeName)
    }

    $DocDefault.Update()
    $web.Dispose()
}

#Add Content Types to a Library
function Add-ContentTypes($url,$listname,$contenttypes,$update){
    $web = Get-SPWeb $url
    switch($contenttypes){
		"IS" {$cttarray = @("Requirements Document","Technical Specifications")}
        "HR" {$cttarray = @("Annual Review")}
    }
    $list = $web.Lists[$listname]
    $list.ContentTypesEnabled = $true
    $list.Update()
    $list = $web.Lists[$listname]

    $result=New-Object System.Collections.Generic.List[Microsoft.SharePoint.SPContentType]

    foreach($cttype in $cttarray){
        $ct = $web.AvailableContentTypes[$cttype]
        if($list.ContentTypes[$ct.Name] -eq $null){
            [void] $list.ContentTypes.Add($ct)
        }
    }
    $list.Update()
    $list = $web.Lists[$listname]
    $currentOrder = $list.ContentTypes
    
    #-----This block sets the default, on an update request we don't want to run this section
    if($update -eq $false){
        foreach ($ct in $currentOrder)
        {
            if ($ct.Name.Contains($cttarray[0]))
            {
                $result.Add($ct)
            }
        }
    	$list.RootFolder.UniqueContentTypeOrder = $result 
	}
	else{
		$list.RootFolder.UniqueContentTypeOrder = $null
	}
	$list.RootFolder.Update()
    #-----End Section we don't want to run
    $web.Dispose()
}

function Add-SiteToProvisioningList($url,$ProvisioningListURL){
    $web = Get-SPWeb $url
    $provWeb = Get-SPWeb $ProvisioningListURL
    $provList = $provWeb.Lists["Site List"]
    $newItem = $provList.Items.Add()
    $newItem["Title"] = $web.Title
    $newItem["Site Path"] = $web.Url


    #Requester
    $requestor = $web.AllProperties["Requestor"]
    $user = $provWeb.EnsureUser($requestor)
    $newItem["Requestor"] = $user

    $newItem["Script Version"] = $web.AllProperties["ScriptVersion"]
    $newItem["Site Type"] = $web.AllProperties["Sitetype"]
    $newItem.Update()

    $web.Update()
    if ($web -ne $null) {
        $web.Dispose()
    }
    $provWeb.Dispose()
}

Function Write-Log($url, $message) {
    #Build the log file name based on the site url.
    $logName = $url
    if ($url.EndsWith("/")) {
        $logName = $url.Substring(0, $web.Url.LastIndexOf("/"))
    }
    $logName = $logName.Substring($logName.LastIndexOf("/")+1)
    $logName = "D:\SP2013\Scripts\Provisioning\"+$logName+"_Log.txt"

    #Write to the log file
    $message >> $logName
}

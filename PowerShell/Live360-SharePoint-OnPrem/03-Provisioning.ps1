#region provisioning sites
function Provision-TeamSite($url,$name,$requestor,$sitetype){
    . E:\Github\Presentations\PowerShell\Live360-SharePoint-OnPrem\FunctionFiles\ReportingFunctions.ps1

    #Get the template you want to use
    $siteTemplate = Get-SPWebTemplate | ? {$_.Title -eq "Team Site" -and $_.CompatibilityLevel -eq "15"}
    #Splatting
    $siteColProperties = @{
        Url = $url;
        OwnerAlias='navuba\spadmin';
        SecondaryOwnerAlias = 'navuba\bstegink';
        Template = $siteTemplate;
        Name = $name;
    }

    #create a new site
    New-SPSite @siteColProperties

    #Set the script version
    $scriptversion = "1.0.1"
    $web = Get-SPWeb $url

    #Evnironment can be: "DEV", "TEST", "PROD"
	$env = "PROD"

    #set site properties
	$web.AllProperties["ScriptVersion"] = $scriptversion
    $web.AllProperties["Requestor"] = $requestor
    $web.AllProperties["Sitetype"] = $sitetype
	$web.Update()

    #set environment specefic variables
    switch($env){
		"DEV" {
            $farmadmin = "dev-spadmin"
			$FarmAdminsGroup = "AD Security Group"
            
            #Provisioning List
            $ProvisioningListUrl = "http://dev-intranet/provisioning"    
		}
		"TEST" {
            $farmadmin = "test-spadmin"
			$FarmAdminsGroup = "AD Security Group"
            
            #Provisioning List
            $ProvisioningListUrl = "http://test-intranet/provisioning"
		}
		"PROD" {
            $farmadmin = "spadmin"
			$FarmAdminsGroup = "AD Security Group"

            #Provisioning List
            $ProvisioningListUrl = "http://intranet/provisioning"

		}
	}

    $web.Dispose()

    #New Site Owner Group and Permissions
	Create-SharePointPermissionLevel "Site Owner" $url
    Create-SharePointGroup -groupname "Site Owner" -url $url -permissionLevel "Site Owner" -farmadmin $farmadmin
    Add-GroupToSecurityQL $url ($web.Title + " Site Owner")

    Add-SiteCollectionAdmin -url $url -user $requestor

    Activate-TeamSiteFeatures -url $url

    if($sitetype -eq "IS"){
        Add-ContentTypes -url $url -listname "Documents" -contenttypes "IS" -update $true           
    }
    if($sitetype -eq "HR"){
        Add-ContentTypes -url $url -listname "Documents" -contenttypes "HR" -update $true
    }
    Set-FieldDefaults -url $url -listName "Documents"

    Create-SearchNavigation -url $url -sitetype $sitetype

    Add-SiteToProvisioningList -url $url -ProvisioningListURL "http://intranet/provisioning"
}
#endregion
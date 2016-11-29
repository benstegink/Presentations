Add-PSSnapin microsoft.sharepoint.powershell

. E:\Github\Presentations\PowerShell\Live360-SharePoint-OnPrem\FunctionFiles\AutomatedTaskFunctions.ps1

#region CT Field Read Only
$web = Get-SPWeb "http://intranet/sites/siterequest12"
$fieldname = "Conference"

$web.Name
$List = $web.Lists["Live360"]
$ct = $List.ContentTypes
foreach ($c in $ct)
{
    $c.Name
    $Field=$c.FieldLinks[$fieldname]
    if($Field -ne $null){
        $Field.ReadOnly = $true
        $c.Update()
    }
}
$web.Dispose()
#endregion

break

#region publish content types
$hub = Get-SPTimerJob | ? {$_.Name -match "metadatahubtimerjob"}
Write-Host "Hub Timer Job last run at" $hub.LastRunTime -ForegroundColor Yellow
$subs = Get-SPTimerJob | ? {$_.Name -match "metadatasubscribertimerjob"}
$subs | % {Write-Host "Subscriber Job on Web Application" $_.WebApplication.DisplayName "last run at:" $_.LastRunTime -ForegroundColor Yellow}

Publish-SPContentTypeHub "http://cth" "NAVUBA Content Types"
Publish-SPContentTypeHub "http://cth" "NAVUBA Project Content Types"
$hub = Get-SPTimerJob | ? {$_.Name -match "metadatahubtimerjob"}
$hub.RunNow()
sleep -Seconds 20
Write-Host "Hub Timer Job last run at" $hub.LastRunTime -ForegroundColor Yellow
$subs | % {$_.RunNow()}
sleep -Seconds 20
$subs = Get-SPTimerJob | ? {$_.Name -match "metadatasubscribertimerjob"}
$subs | % {$_.RunNow()}
$subs | % {Write-Host "Subscriber Job on Web Application" $_.WebApplication.DisplayName "last run at:" $_.LastRunTime  -ForegroundColor Yellow}

#endregion

break

#region Library Views
$web = Get-SPWeb http://intranet/sites/it
$list = $web.Lists["Documents"]
$list.Views | ft Title
Create-SPListView -list $List -viewname "Technical Documents"
Create-SPListView -list $List -viewname "Project Documents"

break

#endregion

#region looping
#Add New Content type to Documents all IT Sites (based on URL)
$wa = Get-SPWebApplication
foreach($a in $wa){
    # Perform Actions on Web App
    $sites = $a | Get-SPSite
    foreach($site in $sites){
        #Perform Actions on Site Collections
        $webs = $site.AllWebs
        foreach($web in $webs){
            # Perform Actions on Webs Here

            if($web.Url -match "/IT/"){
                Write-Host "Updating" $web.Url -ForegroundColor Green
                Add-SPContentType -weburl $web.Url -listname "Documents" -contenttype "Requirements Document"
            }
            else{
                Write-Host "Web:" $web.Url -ForegroundColor Yellow
            }
        }
    }
}

break

#Add New Content type to Documents all IT Sites (based on sitetype)
$wa = Get-SPWebApplication
foreach($a in $wa){
    # Perform Actions on Web App
    $sites = $a | Get-SPSite
    foreach($site in $sites){
        #Perform Actions on Site Collections
        $webs = $site.AllWebs
        foreach($web in $webs){
            # Perform Actions on Webs Here

            if($web.AllProperties["Sitetype"] -eq "IS"){
                Write-Host "Updating" $web.Url -ForegroundColor Green
                Add-SPContentType -weburl $web.Url -listname "Documents" -contenttype "Requirements Document"
            }
            else{
                Write-Host "Web:" $web.Url -ForegroundColor Yellow
            }
        }
    }
}

#Enable Feature on all sites
#region enable features
$sites = Get-SPWebApplication http://intranet | Get-SPSite -Limit ALL | foreach{$_.Url}
$sites | % { if((Get-SPFeature -Identity ef30e082-1149-44fb-8bbc-b085cd995405 -Site $_ -ErrorAction SilentlyContinue) -eq $null){Write-Host "Enable Feature on $_";Enable-SPFeature -Identity ef30e082-1149-44fb-8bbc-b085cd995405  -URL $_}}
#-or-

foreach($site in $sites){
    if((Get-SPFeature -Identity ef30e082-1149-44fb-8bbc-b085cd995405 -Site $site -ErrorAction SilentlyContinue) -eq $null){
        Write-Host "Enable Feature on $site";
        Enable-SPFeature -Identity ef30e082-1149-44fb-8bbc-b085cd995405  -URL $site
    }    
}
#endregion
#endregion

#region user profile properties

ListUPPDisplayOrder http://mysite
UPPReorder E:\UserProperyOrderTest.xml http://mysite

#endregion


#region provisioning sites
function Provision-TeamSite($url,$name,$requestor,$sitetype){
    . E:\Github\Presentations\PowerShell\Live360-SharePoint-OnPrem\FunctionFiles\Provisioning-Functions.ps1

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
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
$sites = Get-SPWebApplication http://sb1-portal.aptargroup.loc | Get-SPSite -Limit ALL | foreach{$_.Url}
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
Add-PSSnapin microsoft.sharepoint.powershell

. F:\GitHub\Presentations\PowerShell\Live360-SharePoint2016-Tasks\FunctionFiles\AutomatedTaskFunctions.ps1

break

#region CT Field Read Only
$web = Get-SPWeb "http://sp16-intranet/team/T_23"
$fieldname = "DocStatus"

$web.Name
$List = $web.Lists["Documents"]
$ct = $List.ContentTypes
foreach ($c in $ct)
{
    if($c.Name -ne "Folder" -and $c.Name -ne "Document"){
        $c.Name
        $c.ReadOnly = $false
        $c.Update()
        $Field=$c.FieldLinks[$fieldname]
        if($Field -ne $null){
            $Field.ReadOnly = $true
            $c.Update()
        }
        $c.ReadOnly = $true
        $c.Update()
    }
}
$web.Dispose()
#endregion

break

#region publish content types
$hub = Get-SPTimerJob | ? {$_.Name -match "metadatahubtimerjob"}
$hublastrun = $hub.LastRunTime
Write-Host "Hub Timer Job last run at" $hub.LastRunTime -ForegroundColor Yellow
$subs = Get-SPTimerJob | ? {$_.Name -match "metadatasubscribertimerjob"}
$subs | % {Write-Host "Subscriber Job on Web Application" $_.WebApplication.DisplayName "last run at:" $_.LastRunTime -ForegroundColor Yellow}

#Publish-SPContentTypeHub "http://cth.navuba.loc" "Navuba"
#Publish-SPContentTypeHub "http://cth.navuba.loc" "Navuba HR"
#Publish-SPContentTypeHub "http://cth.navuba.loc" "Navuba IT"
Publish-SPContentTypeHub "http://cth.navuba.loc" "Navuba Project"
$hub = Get-SPTimerJob | ? {$_.Name -match "metadatahubtimerjob"}
$hub.RunNow()
while($hublastrun -eq $hub.LastRunTime){
    Write-Host "Hub Timer Job running..." -ForegroundColor Yellow
    $hub = Get-SPTimerJob | ? {$_.Name -match "metadatahubtimerjob"}
    sleep -Seconds 5
}
Write-Host "Hub Timer Job completed at at" $hub.LastRunTime -ForegroundColor Green
$subs = Get-SPTimerJob | ? {$_.Name -match "metadatasubscribertimerjob"}
$subs | % {$_.RunNow();Write-Host "Subscriber Job as been started on Web Application" $_.WebApplication.DisplayName -ForegroundColor Green}
#endregion

break



#region looping
#Add New Content type to Documents all project Sites (based on URL)
$wa = Get-SPWebApplication
foreach($a in $wa){
    # Perform Actions on Web App
    $sites = $a | Get-SPSite
    foreach($site in $sites){
        #Perform Actions on Site Collections
        $webs = $site.AllWebs
        foreach($web in $webs){
            # Perform Actions on Webs Here

            if($web.Url -match "/project/"){
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



break

#region Library Views
$web = Get-SPWeb http://intranet/sites/it
$list = $web.Lists["Documents"]
$list.Views | ft Title
Create-SPListView -list $List -viewname "Technical Documents"
Create-SPListView -list $List -viewname "Project Documents"

#endregion

break



#Other Things you can automate
#  - Reordering User Profile Properties
#

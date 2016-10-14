#Apply something to all sites

$webs = Get-SPWebApplication http://intranet | Get-SPSite -Limit ALL | Get-SPWeb -Limit ALL
$webs

#region lists and libraries

#look for library on every site
foreach($web in $webs){
    #do something here
    $list = $web.Lists | ? {$_.Title -eq "My Automated List"}
    if($list -ne $null){
        Write-Host "Web:" $web.Title "with URL:" $web.Url "contains 'My Automated List'" -ForegroundColor Green
    }
    else{
        Write-Host "Web:" $web.Title "with URL:" $web.Url "does not contain 'My Automated List'" -ForegroundColor Red
    }
}

#add a library on every site
foreach($web in $webs){
    #do something here
    $web.Lists.Add("My Automated List","I added this list with a PS Script","DocumentLibrary")
}

#remove a library for ever site
foreach($web in $webs){
    $list = $web.Lists | ? {$_.Title -eq "My Automated List"}
    if($list -ne $null){
        $list.Delete()
    }
    else{
        Write-Host "Web:" $web.Title "with URL:" $web.Url "does not contain 'My Automated List'" -ForegroundColor Red
    }
}

#endregion


#region site properties
$web.AllProperties
$web.Properties
$web.AllProperties.Add("My Property Name","Property Value")

foreach($web in $webs){
    if($web.AllProperties["SiteVersion"] -eq "1.0.1"){
        Write-Host $web.Title "-" $web.AllProperties["SiteVersion"] -ForegroundColor Green
    }
    else{
        Write-Host $web.Title "needs to be updated to version 1.0.1" -ForegroundColor Yellow
    }
}

#endregion

#region content types

function Publish-ContentTypeHub {
    param
    (
        [parameter(mandatory=$true)][string]$CTHUrl,
        [parameter(mandatory=$true)][string]$Group
    )
 
    $site = Get-SPSite $CTHUrl
    if(!($site -eq $null))
    {
        $contentTypePublisher = New-Object Microsoft.SharePoint.Taxonomy.ContentTypeSync.ContentTypePublisher ($site)
        $site.RootWeb.ContentTypes | ? {$_.Group -match $Group} | % {
            $contentTypePublisher.Publish($_)
            write-host "Content type" $_.Name "has been republished" -foregroundcolor Green
        }
    }
}
Publish-ContentTypeHub "http://cth" "NAVUBA Content Types"


#endregion
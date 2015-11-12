. E:\Github\Presentations\PowerShell\Live360-SharePoint-OnPrem\FunctionFiles\AutomatedTaskFunctions.ps1


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
            }
            else{
                Write-Host "Web:" $web.Url -ForegroundColor Yellow
            }
        }
    }
}




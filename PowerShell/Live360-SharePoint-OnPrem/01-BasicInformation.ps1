Add-PSSnapin microsoft.sharepoint.powershell

########## Web Applications ##########
#Get all Web Applications
$wa = Get-SPWebApplication

#Reporting on Web Applications
$wa.Count
$wa | ft Name, URL

break

########## Site Collections ##########
#Get all Site Collections
$sites = $wa | Get-SPSite -Limit ALL
#-or-
$sites = Get-SPWebApplication | Get-SPSite -Limit ALL
$sites.Count
#-or-
$sites = Get-SPSite -Limit ALL
$sites.Count

#All Site Collections
$sites | ft Url

#Since sites are a "shell" no name or title, the rootweb has the Title
$site = $sites[1]
$site


break

########## Webs ##########
#Get all Sites
$webs = $sites | Get-SPWeb -Limit ALL
#-or-
$webs = Get-SPWebApplication | Get-SPSite -Limit ALL | Get-SPWeb -Limit ALL
$webs.Count
$webs | ft Title,Url

break


#Looping
$wa = Get-SPWebApplication
foreach($a in $wa){
    # Perform Actions on Web App
    Write-Host "Web Application:" $a.Url -ForegroundColor Green
    $sites = $a | Get-SPSite
    foreach($site in $sites){
        #Perform Actions on Site Collections
        Write-Host "Site Collection:" $site.Url -ForegroundColor cyan
        $webs = $site.AllWebs
        foreach($web in $webs){
            # Perform Actions on Webs Here
            Write-Host "Web:" $web.Url -ForegroundColor Yellow
        }
    }
}

break

$webs = Get-SPWebApplication | Get-SPSite -Limit ALL | Get-SPWeb -Limit ALL
foreach($web in $webs){
    Write-Host $web.Title ":" -ForegroundColor Yellow
    Write-Host `t $web.Url -ForegroundColor Green
}


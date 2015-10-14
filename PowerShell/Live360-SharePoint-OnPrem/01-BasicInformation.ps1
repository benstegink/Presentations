$bp = Set-PSBreakpoint -Variable wait -Mode Write -Script $psISE.CurrentFile.FullPath

########## Web Applications ##########
#Get all Web Applications
$wa = Get-SPWebApplication

#Reporting on Web Applications
$wa.Count
$wa | ft Name, URL

$wait = "Here"

########## Site Collections ##########
#Get all Site Collections
$sites = $wa | Get-SPSite -Limit ALL
#-or-
$sites = Get-SPWebApplication | Get-SPSite -Limit ALL
$sites.Count
#Since sites are a "shell" no name or title, the rootweb has the Title
$sites | ft Url

$wait = "Here"

########## Webs ##########
#Get all Sites
$webs = $sites | Get-SPWeb -Limit ALL
#-or-
$webs = Get-SPWebApplication | Get-SPSite -Limit ALL | Get-SPWeb -Limit ALL
$webs.Count
$webs | ft Title,Url

$wait = "here"


#Looping
foreach($a in $wa){
    # Perform Actions on Web App
    Write-Host "Web Application:" $a.Url -ForegroundColor Green
    $sites = $wa | Get-SPSite
    foreach($site in $sites){
        #Perform Actions on Site Collections
        Write-Host "Site Collection:" $site.Url -ForegroundColor Red
        $webs = $site.AllWebs
        foreach($web in $webs){
            # Perform Actions on Webs Here
            Write-Host "Web:" $web.Url -ForegroundColor Yellow
        }
    }
}

$wait = "Here"

$webs = Get-SPWebApplication | Get-SPSite -Limit ALL | Get-SPWeb -Limit ALL
foreach($web in $webs){
    Write-Host $web.Title ":" $web.Url
}


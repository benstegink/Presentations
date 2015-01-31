#Functions
function Get-SharePointCounts([string]$webapp){
    $wa = Get-SPWebApplication -Identity $webapp
    $sitecols = $wa | Get-SPSite -Limit ALL
    $webs = $sitecols | Get-SPWeb -Limit All
    
    Write-Host "You have" $sitecols.Count "site collections"
    #foreach($site in $sitecols){
    #    Write-Host $site.RootWeb.Title "(" $site.Url ")" -ForegroundColor Green
    #}

    Write-Host "You have" $webs.Count "webs - includes root webs"
    foreach($web in $webs){
        if($web.IsRootWeb -eq $true){
            Write-Host $web.Title "(" $web.Url ")" -ForegroundColor Green
        }
        if($web.IsRootWeb -eq $false){
            Write-Host $web.Title "(" $web.Url ")" -ForegroundColor Cyan
        }
    }
    Write-Host ""

    foreach($web in $webs){
        $lists = $web.Lists
        
        Write-Host "In" $web.Title "(" $web.Url ") you have" $lists.Count "lists" -ForegroundColor Yellow
        #Write-Host "You have" $web.Lists.Count "lists"
    }

}
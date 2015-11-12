function Add-SPContentType ($weburl,$listname,$contenttype){
    $web = Get-SPWeb $weburl
    $list = $web.Lists[$listname]
    if($list.ContentTypesEnabled -ne $true){
        $list.ContentTypesEnabled = $true
        $list.Update()
    }
    $libct = $list.ContentTypes[$contenttype]
    if($libct -eq $null){
        $ct = $web.AvailableContentTypes[$contenttype]
        if($ct -ne $null){
            [void] $list.ContentTypes.Add($ct)
            $list.Update()
            Write-Host "The Content Type" $contenttype "was succesfully added to the library" $listname "on site" $web.Url -ForegroundColor Green
        }
        else{
            Write-Host "The Content Type" $contenttype "wasn't available on the site" $web.Url "to add to the library" $listname -ForegroundColor Red
        }
    }
    else{
        Write-Host "The Content Type" $contenttype "has already been added to the library" $listname "on site" $web.Url -ForegroundColor Yellow
    }
}
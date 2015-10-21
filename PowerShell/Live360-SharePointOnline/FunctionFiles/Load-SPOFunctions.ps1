function Create-SiteObject($Url,$AllowSPDesigner,$Storage){
    $obj = New-Object PSObject
    $obj | Add-Member NoteProperty URL $Url
    $Obj | Add-Member NoteProperty AllowSPDesigner $AllowSPDesigner
    $obj | Add-Member NoteProperty Storage $Storage

    return $obj
}

function Get-SubWebs($url,$creds){
    Connect-SPOnline -Url $url -Credentials $creds
    $subwebs = Get-SPOSubWebs
    if($subwebs -eq $null){
        $web = Get-SPOWeb
        return $web
    }
    else{
        foreach($web in $subwebs){
            Get-SubWebs -url $web.Url -creds $creds
        }
        Connect-SPOnline -Url $url -Credentials $creds
        $web2 = Get-SPOWeb
        return $web2
    }
}
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

function Get-SPOUid($loginName,$web){
    $user = $web.EnsureUser($loginName)
    $web.Context.Load($user)
    $web.Context.ExecuteQuery()
    return $user
}

function Get-SPOListFields($list){
    $fields = $list.Fields
    $list.Context.Load($fields)
    $list.Context.ExecuteQuery()
    return $fields
}

function Get-SPOLicensedUsers($users){
    $spusers = @()
    foreach($user in $users){
        if($user.IsLicensed -eq $true){
            $status = $user.Licenses.ServiceStatus
            foreach($s in $status){
                if($s.ServicePlan.ServiceType -eq "SharePoint"){
                    $userLic = New-Object PSObject
                    $userLic | Add-Member NoteProperty DisplayName $user.DisplayName
                    $userLic | Add-Member NoteProperty SPLicenseType $s.ServicePlan.ServiceName
                    $spusers += $userLic
                }
            }
        }
    }
    return $spusers
}
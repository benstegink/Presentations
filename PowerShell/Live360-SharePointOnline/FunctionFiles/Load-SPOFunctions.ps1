function Create-SiteObject($Url,$AllowSPDesigner){
    $obj = New-Object PSObject
    $obj | Add-Member NoteProperty URL $Url
    $Obj | Add-Member NoteProperty AllowSPDesigner $AllowSPDesigner


    return $obj
}
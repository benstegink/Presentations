########## Functions ##########
function Get-SPSiteCollectionSize([string]$StorageUnit,$site){
    $usage = $site.Usage.Storage
    if($StorageUnit = "MB"){
        $usage = $usage/1MB
    }
    elseif($StorageUnit = "GB"){
        $usage = $usage/1GB
    }
    return $usage
}

function Get-SPSiteCollectionDocuments($site){
    $lists = $site.RootWeb.Lists | ? {$_.IsCatalog -eq $false -and $_.BaseTemplate -eq "DocumentLibrary" -and $_.IsSiteAssetsLibrary -eq $false -and $_.EntityTypeName -ne "FormServerTemplates"}
    $itemcount = 0
    foreach($list in $lists){
        $itemcount = $itemcount+$list.ItemCount
    }
    return $itemcount
}

########## End Functions ##########
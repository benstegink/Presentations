$url = "http://intranet/site/TeamSite1"
$siteColOwner = "sp2013ben\spadmin"
$siteColSecondaryOwner = "sp2013ben\bstegink"

#Find the WEb Template you want to use

Get-Command *Template*

Get-SPWebTemplate
Get-SPWebTemplate | where {$_.CompatibilityLevel -eq "15"}
Get-SPWebTemplate | ? {$_.Title -eq "Team Site"}
Get-SPWebTemplate | ? {$_.Title -eq "Team Site" -and $_.CompatibilityLevel -eq "15"}
$siteTemplate = Get-SPWebTemplate | ? {$_.Title -eq "Team Site" -and $_.CompatibilityLevel -eq "15"}

New-SPSite -Url "http://intranet/sites/TeamSite1" -OwnerAlias $siteColOwner -SecondaryOwnerAlias $siteColSecondaryOwner -Template $siteTemplate
$site = New-SPSite -Url "http://intranet/sites/TeamSite1" -OwnerAlias $siteColOwner -SecondaryOwnerAlias $siteColSecondaryOwner -Template $siteTemplate

New-SPWeb -Url "http://intranet/sites/TeamSite1/SubSite1" -Template $siteTemplate
$web = New-SPWeb -Url "http://intranet/sites/TeamSite1/SubSite1" -Template $siteTemplate
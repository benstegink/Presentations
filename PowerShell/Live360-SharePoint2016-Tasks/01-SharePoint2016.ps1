Add-PSSnapin microsoft.sharepoint.powershell

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module SharePointPnPPowerShell2016

Get-SPWebTemplatesEnabledForSiteMaster
Get-SPSiteMaster -ContentDatabase SP2016_Content_SP16-Intranet

Enable-SPWebTemplateForSiteMaster -Template STS#1
New-SPSiteMaster -ContentDatabase SP2016_Content_SP16-Intranet -Template STS#1

#Site Templates - https://absolute-sharepoint.com/2013/06/sharepoint-2013-site-template-id-list-for-powershell.html
New-SPSite -Url http://sp16-intranet/sites/fastsite2 -Template STS#0 -CreateFromSiteMaster -OwnerAlias navuba\spadmin -SecondaryOwnerAlias navuba\ben

Merge-SPUsageLog -Identity "Administrative Actions" -StartTime 12/1/2016 | Select User, ActionName, Timestamp | Sort Timestamp

Get-SPServiceApplicationProxy | ft DisplayName
Get-SPConnectedServiceApplicationInformation

$proxy = Get-SPServiceApplicationProxy | ? {$_.DisplayName -eq "Managed Metadata Service Application Proxy"}
$proxyhealth = Get-SPConnectedServiceApplicationInformation -ServiceApplicationProxy $proxy
$proxyhealth.ApplicationAddressesState
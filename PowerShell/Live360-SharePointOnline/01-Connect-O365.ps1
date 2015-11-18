# Launch SharePoint Online Management Shell
# Launch ISE

# Get Cmdlets
# Microsoft Online Cmdlets (Azure AD)
Get-Command -Module MSOnline
# Microsoft SPO Cmdlets
Get-Command -Module Microsoft.Online.SharePoint.PowerShell
# OfficeDev PnP Cmdlets
Get-Command -Module OfficeDevPnP.PowerShell.Commands

#Connect to Office 365/Azure AD
Connect-MsolService

#Duplicate cmdlets
Get-Command Get-SPOS*
OfficeDevPnP.PowerShell.Commands\Get-SPOSite
Microsoft.Online.SharePoint.PowerShell\Get-SPOSite

#Connect to SharePoint Online
# Microsoft.Online.SharePoitn.PowerShell
Connect-SPOService -Url https://navuba-admin.sharepoint.com
# OfficeDevPnP.PowerShell.Commands
Connect-SPOnline -Url https://navuba.sharepoint.com

#Other Methods
$creds = Get-Credential
$url = "https://navuba.sharepoint.com"
$adminUrl = "https://navuba-admin.sharepoint.com"

Connect-SPOnline -Url $url -Credentials $creds
Connect-SPOService -Url $adminUrl -Credential $creds
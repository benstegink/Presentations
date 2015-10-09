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

#Connect to SharePoint Online
# Microsoft.Online.SharePoitn.PowerShell
Connect-SPOService -Url https://navuba-admin.sharepoint.com
# OfficeDevPnP.PowerShell.Commands
Connect-SPOnline -Url https://navuba.sharepoint.com


. C:\Github\Presentations\PowerShell\Live360-SharePointOnline\FunctionFiles\Load-SPOFunctions.ps1

$creds = Get-Credential
$url = "https://navuba.sharepoint.com"
$adminUrl = "https://navuba-admin.sharepoint.com"

#connect to OfficeDevPnP.PowerShell.Commands
Connect-SPOnline -Url $url -Credentials $creds

#Connect to Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url $adminUrl -Credential $creds

#connect to Microsoft Online/Office 365
Connect-MsolService -Credential $creds

break

#Get a User
#Get Azure AD Users
Get-MsolUser
#Get Users in a Site Collection
Get-SPOUser -Site "https://navuba.sharepoint.com/"

#region licenses
#View Users licensed for SPO
$users = Get-MsolUser
$user = Get-MsolUser -UserPrincipalName bryan@navuba.com
$user.Licenses.ServiceStatus

#Get-SPOLicensedUsers is a custom fuction
$licUsers = Get-SPOLicensedUsers -users $users
$licUsers

#Account Skus
Get-MsolAccountSku

Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -RemoveLicenses "NAVUBA:STANDARDWOFFPACK"
Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -AddLicenses "NAVUBA:STANDARDWOFFPACK"

$user = Get-MsolUser -UserPrincipalName bryan@navuba.com
$user.Licenses.ServiceStatus

$license = New-MsolLicenseOptions -AccountSkuId "NAVUBA:STANDARDWOFFPACK" -DisabledPlans "EXCHANGE_S_STANDARD"
Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -LicenseOptions $license

$user = Get-MsolUser -UserPrincipalName bryan@navuba.com
$user.Licenses.ServiceStatus
#endregion

#Remove User/Disable User
$site = OfficeDevPnP.PowerShell.Commands\Get-SPOSite
$users = Get-SPOUser -Site https://navuba.sharepoint.com
$user = $users | ? {$_.DisplayName -eq "Bryan Smith"}

#Remove
Remove-SPOUser -LoginName $user.LoginName -Site https://navuba.sharepoint.com

#Add User
Add-SPOUserToGroup -LoginName $user.LoginName -Identity Owners
Add-SPOUser -LoginName $user.LoginName -Site https://navuba.sharepoint.com -Group "Members"



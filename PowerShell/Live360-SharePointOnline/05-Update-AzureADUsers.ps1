#Get a User
#Get Azure AD Users
Get-MsolUser
#Get Users in a Site Collection
Get-SPOUser -Site "https://navuba.sharepoint.com/"

#View Users licensed for SPO
$user = Get-MsolUser -UserPrincipalName ben@navuba.com

#Remove User/Disable User
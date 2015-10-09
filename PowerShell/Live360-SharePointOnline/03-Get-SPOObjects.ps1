#Get the Client Context
function Get-SPOClientContext(){
	$loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
	$loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
	
	$siteUrl =  Read-Host -Prompt "SiteURL"
	$username = Read-Host -Prompt "Enter username" 
	$password = Read-Host -Prompt "Enter password" -AsSecureString
	
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
	$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $password) 
	$ctx.Credentials = $credentials
	return $ctx
}

#Site Collection
$site = $ctx.Site
$ctx.Load($site)
$ctx.ExecuteQuery()

########## Web #########
$web = $site.RootWeb
$ctx.Load($web)
$ctx.ExecuteQuery()

#Sub Webs
foreach($web in $web.Webs){Write-Host $web.Title " - " $web.Url}
$webs = $web.Webs
$ctx.Load($webs)
$ctx.ExecuteQuery()

$webs - # Doesn't Work
#You need to use:
foreach($web in $web.Webs)
{
	Write-Host $web.Title " - " $web.Url
}

#List

#List Item
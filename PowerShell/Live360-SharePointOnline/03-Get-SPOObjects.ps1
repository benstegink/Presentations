$bp = Set-PSBreakpoint -Variable wait -Mode Write -Script $psISE.CurrentFile.FullPath
$using = "CSOM"

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

$wait = "Here"

$ctx = Get-SPOClientContext

$wait= "Here"

if($using = "CSOM"){
    #Site Collection
    $site = $ctx.Site
    $features = $site.Features
    $ctx.Load($features)
    $ctx.Load($site)
    $ctx.ExecuteQuery()
    Write-Host $features

    $wait = "Here"

    ########## Web #########
    #Get the Root Web
    $web = $site.RootWeb
    $ctx.Load($web)
    $ctx.ExecuteQuery()

    #Get the root web properties
    $prop = $web.AllProperties
    $ctx.Load($prop)
    $ctx.ExecuteQuery()

    #Sub Webs
    $webs = $web.Webs
    $ctx.Load($webs)
    $ctx.ExecuteQuery()

    #$webs # Doesn't Work

    #You need to use:
    foreach($subweb in $web.Webs)
    {
	    
        $prop = $subweb.AllProperties
        $sw = $subweb.Webs
        $ctx.Load($sw)
        $ctx.Load($prop)
        $ctx.ExecuteQuery()
        if($subweb.Url -ne $site.RootWeb.Url){
            Write-Host $subweb.Title " - " $web.Url
            Write-Host "The Number of Subwebs is:" $sw.Count
            Write-Host "Inherit Parent Navigation:" $subweb.AllProperties.FieldValues.__InheritCurrentNavigation
        }
    }

    #List

    #List Item
}

$wait = "Here"

if($using = "DEVPnP"){
    #Site Collection

    ########## Web #########
    #Get the Root Web

    #Get the root web properties

    #Sub Webs

    #List

    #List Item
}
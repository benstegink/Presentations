$bp = Set-PSBreakpoint -Variable wait -Mode Write -Script $psISE.CurrentFile.FullPath

$wait = "Here"

$creds = Get-Credential
$url = "https://navuba.sharepoint.com"
$adminUrl = "https://navuba-admin.sharepoint.com"

Connect-SPOnline -Url $url -Credentials $creds
Connect-SPOService -Url $adminUrl -Credential $creds

$wait = "here"

#region Get Basic Info

#Get Office Online Info
Get-MsolCompanyInformation

#Get SharePoint Online Info
Get-SPOTenant

#endregion

$wait = "here"

#region Site Collections

foreach($site in $sites){
    if($site.Url -notmatch "http://www"){
        Connect-SPOnline -Url $site.Url -Credentials $creds
        $DevPnPSite = OfficeDevPnP.PowerShell.Commands\Get-SPOSite

        $wait="here"
    }

}

#endregion

$wait = "here"



########## Web #########
#Get the Root Web

#Get the root web properties

#Sub Webs

#List

#List Item
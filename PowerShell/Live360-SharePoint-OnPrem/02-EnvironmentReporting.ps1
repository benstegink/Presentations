########## Variables ##########
#$webApp = "http://intranet"
$mysitesURL = "http:mysite"
########## End Variables #########

Add-PSSnapin microsoft.sharepoint.powershell

#Load Functions
. E:\Github\Presentations\PowerShell\Live360-SharePoint-OnPrem\FunctionFiles\ReportingFunctions.ps1
. E:\Github\Presentations\PowerShell\Live360-SharePoint-OnPrem\FunctionFiles\Export-XLSX.ps1

$sites = Get-SPWebApplication | Get-SPSite -Limit ALL
$siteReport = @()
$con = New-Object System.Data.SQLClient.SqlConnection
#On Prem
#$con.ConnectionString = "Data Source=SQLServerL;Initial Catalog=Databaseg;User ID=spReporting;Password=mypassword"
#Azure
#Get Credentials from a file, use https://github.com/benstegink/PowerShellScripts/blob/master/Misc/Create-CredentialFile.ps1 to create the file and make it of type SQL
$password = get-content C:\Users\spadmin\Documents\AzureDBCreds.txt | ConvertTo-SecureString
$creds = New-Object System.Management.Automation.PSCredential -argumentlist "OnPremReporting",$password
$username = $creds.UserName
$password = $creds.GetNetworkCredential().Password


$con.ConnectionString = "Server=tcp:sharepointdata.database.windows.net;Database=SharePoitnOnPrem;User ID=$username;Password=$password;Trusted_Connection=False;Encrypt=True;"
$con.Open()
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.Connection = $con

foreach($site in $sites){
    $siteObject = New-Object PSObject
    $usage = Get-SPSiteCollectionSize -StorageUnit "MB" -site $site
    $items = Get-SPSiteCollectionDocuments -site $site
    $usageString = $usage.ToString("#.##")
    $date = Get-Date
    $date = $date.ToShortDateString()
    $sitetype = $site.RootWeb.AllProperties["Sitetype"]
    if($site.RootWeb.Url -match "http://mysite"){
        $sitetype = "MySite"
    }

    $cmd.CommandText = "INSERT INTO SiteCollections (Date,SiteTitle,SiteUrl,SizeInMB,Documents,LastItemModified,Sitetype) VALUES('{0}','{1}','{2}','{3}','{4}','{5}','{6}')" -f $date,$site.RootWeb.Title,$site.Url,$usageString,$items,$site.RootWeb.LastItemModifiedDate,$sitetype
    $cmd.ExecuteNonQuery()
}
$con.Close()
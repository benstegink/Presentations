########## Variables ##########
$webApp = "http://webapplication"
########## End Variables #########

#Load Functions
. D:\SP2013\Scripts\Reports\Reporting-Functions.ps1
. D:\SP2013\Scripts\Provisioning\Common\Export-XLSX.ps1

$sites = Get-SPWebApplication $webApp | Get-SPSite -Limit ALL
$siteReport = @()
$con = New-Object System.Data.SQLClient.SqlConnection
$con.ConnectionString = "Data Source=SQLServerL;Initial Catalog=Databaseg;User ID=spReporting;Password=mypassword"
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

    $cmd.CommandText = "INSERT INTO SiteCollections (Date,SiteTitle,SiteUrl,SizeInMB,Documents,LastItemModified) VALUES('{0}','{1}','{2}','{3}','{4}','{5}')" -f $date,$site.RootWeb.Title,$site.Url,$usageString,$items,$site.RootWeb.LastItemModifiedDate
    $cmd.ExecuteNonQuery()
}
$con.Close()
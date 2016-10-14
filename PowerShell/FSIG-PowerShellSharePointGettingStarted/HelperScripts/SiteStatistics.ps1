########## Variables ##########
$webApp = "http://intranet"
########## End Variables #########

if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

#Load Functions
. E:\Github\Presentations\PowerShell\FSIG-PowerShellSharePointGettingStarted\HelperScripts\Reporting-Functions.ps1
. E:\Github\Presentations\PowerShell\FSIG-PowerShellSharePointGettingStarted\HelperScripts\Export-XLSX.ps1

$sites = Get-SPWebApplication $webApp | Get-SPSite -Limit ALL
$siteReport = @()
##### If Writing to a SQL Databases uncomment and update
#$con = New-Object System.Data.SQLClient.SqlConnection
#$con.ConnectionString = "Data Source=dbserver;Initial Catalog=sqltable;User ID=sqluser;Password=password"
#$con.Open()
#$cmd = New-Object System.Data.SqlClient.SqlCommand
#$cmd.Connection = $con
##### End Opening SQL Connection

foreach($site in $sites){
    $siteObject = New-Object PSObject
    $usage = Get-SPSiteCollectionSize -StorageUnit "MB" -site $site
    $items = Get-SPSiteCollectionDocuments -site $site
    $usageString = $usage.ToString("#.##")
    $date = Get-Date
    $date = $date.ToShortDateString()

    ##### Write Data toa  SQL Database
    #$cmd.CommandText = "INSERT INTO SiteCollections (Date,SiteTitle,SiteUrl,SizeInMB,Documents,LastItemModified) VALUES('{0}','{1}','{2}','{3}','{4}','{5}')" -f $date,$site.RootWeb.Title,$site.Url,$usageString,$items,$site.RootWeb.LastItemModifiedDate
    #$cmd.ExecuteNonQuery()
    ##### End Writing to a SQL Database

    ##### Write Data to an Excel File
    $siteObject | Add-Member -MemberType NoteProperty -Name "Date" -Value $date
    $siteObject | Add-Member -MemberType NoteProperty -Name "Site Title" -Value $site.RootWeb.Title
    $siteObject | Add-Member -MemberType NoteProperty -Name "Site URL" -Value $site.Url
    $siteObject | Add-Member -MemberType NoteProperty -Name "Size in MB" -Value $usageString
    $siteObject | Add-Member -MemberType NoteProperty -Name "Documents" -Value $items
    $siteObject | Add-Member -MemberType NoteProperty -Name "Last Item Modified" -Value $site.RootWeb.LastItemModifiedDate

    $siteReport += $siteObject
    ##### End Writing to an Excel File   
}
#Output to an Excel File
$siteReport | Export-XLSX -Path E:\SiteReport.xlsx -NoClobber -Append

##### Close the connection to SQL
#$con.Close()
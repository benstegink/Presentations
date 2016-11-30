Start-Transcript F:\Logs\SiteReporting.log
if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

########## Variables ##########
$webApp = "http://sp16-intranet"
$mysitesUrl = "http://mysites"
$destination = "SQL"
$username = "bstegink"
$password = $null
########## End Variables #########

#Load Functions
. F:\GitHub\Presentations\PowerShell\Live360-SharePoint2016-Tasks\Reporting\Reporting-Functions.ps1
. F:\GitHub\Presentations\PowerShell\Live360-SharePoint2016-Tasks\FunctionFiles\Export-XLSX.ps1

$sites = Get-SPWebApplication | Get-SPSite -Limit ALL
$siteReport = @()

if($destination -eq "SQL"){
    $con = New-Object System.Data.SQLClient.SqlConnection
    #On Prem
    #$con.ConnectionString = "Data Source=SQLServerL;Initial Catalog=Databaseg;User ID=spReporting;Password=mypassword"
    #Azure
    #Get Credentials from a file, use https://github.com/benstegink/PowerShellScripts/blob/master/Misc/Create-CredentialFile.ps1 to create the file and make it of type SQL
    if($password -eq $null){
        $password = get-content F:\SQLReportingCredentials.txt | ConvertTo-SecureString
        $creds = New-Object System.Management.Automation.PSCredential -argumentlist $username,$password
        $username = $creds.UserName
        $password = $creds.GetNetworkCredential().Password
    }

    $con.ConnectionString = "Server=tcp:navuba.database.windows.net;Database=SharePoint2016Reporting;User ID=$username;Password=$password;Trusted_Connection=False;Encrypt=True;"
    $con.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand
    $cmd.Connection = $con
}

foreach($site in $sites){
    $sitetype = $null
    $siteObject = New-Object PSObject
    $usage = Get-SPSiteCollectionSize -StorageUnit "MB" -site $site
    $items = Get-SPSiteCollectionDocuments -site $site
    $usageString = $usage.ToString("#.##")
    $date = Get-Date
    $date = $date.ToShortDateString()
    $sitetype = $site.RootWeb.AllProperties["SiteType"]
    $dept = $site.RootWeb.AllProperties["Department"]
    $siteowner = $site.RootWeb.AllProperties["SiteOwner"]
    $siteowneremail = $site.RootWeb.AllProperties["SiteOwnerEmail"]
    if($site.RootWeb.Url -match $mysitesURL){
        $sitetype = "MySite"
    }

    if($destination -eq "SQL"){
        $cmd.CommandText = "INSERT INTO SiteCollections (Date,SiteTitle,SiteUrl,SizeInMB,Documents,LastItemModified,SiteType,Department,SiteOwner,SiteOwnerEmail) VALUES('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}')" -f $date,$site.RootWeb.Title,$site.Url,$usageString,$items,$site.RootWeb.LastItemModifiedDate,$sitetype,$dept,$siteowner,$siteowneremail
        $cmd.ExecuteNonQuery()
    }
    elseif($destination -eq "XLS"){
        $siteObject | Add-Member -MemberType NoteProperty -Name "Date" -Value $date
        $siteObject | Add-Member -MemberType NoteProperty -Name "Site Title" -Value $site.RootWeb.Title
        $siteObject | Add-Member -MemberType NoteProperty -Name "Site URL" -Value $site.Url
        $siteObject | Add-Member -MemberType NoteProperty -Name "Size in MB" -Value $usageString
        $siteObject | Add-Member -MemberType NoteProperty -Name "Documents" -Value $items
        $siteObject | Add-Member -MemberType NoteProperty -Name "Last Item Modified" -Value $site.RootWeb.LastItemModifiedDate

        $siteReport += $siteObject
    }
}

if($destination -eq "SQL"){
    $con.Close()
}
elseif($destination -eq "XLS"){
    #Output to an Excel File
    $siteReport | Export-XLSX -Path E:\SiteReport.xlsx -NoClobber -Append
}

Stop-Transcript
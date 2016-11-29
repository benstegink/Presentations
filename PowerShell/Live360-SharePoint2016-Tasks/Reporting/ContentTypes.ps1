########## Variables ##########
$cth = "http://cth.navuba.loc"
########## End Variables #########

if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

##### SQL Connection
$con = New-Object System.Data.SQLClient.SqlConnection
#Add Azure Connection String
$con.ConnectionString = ""
$con.Open()
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.Connection = $con

$web = Get-SPWeb $cth
$date = Get-Date -Format "MM/dd/yyyy"
#$date = "12/31/2015"

#region columns

$columns = $web.Fields | ? {$_.Group -match "Navuba"}

$cmd.CommandText = "Update tblColumns Set InProd = '{0}'" -f 0
$cmd.ExecuteNonQuery()
$cmd.CommandText = "Update tblContentTypes Set InProd = '{0}'" -f 0
$cmd.ExecuteNonQuery()
$cmd.CommandText = "Update tblColumnToContentType Set InProd = '{0}'" -f 0
$cmd.ExecuteNonQuery()
$cmd.CommandText = "Update tblColumnValues Set InProd = '{0}'" -f 0
$cmd.ExecuteNonQuery()
#$cmd.CommandText = "DELETE FROM ColumnValues;"
#$cmd.ExecuteNonQuery()

#####Write all fields to database
foreach($field in $columns){
    $id = $field.Id
    $group = $field.Group
    $displayName = $field.Title
    $internalName = $field.StaticName
    $type = $field.TypeDisplayName
    $defaultValue = $field.DefaultValue
    $description = $field.Description

    if($field.Type -eq "MultiChoice"){
        $multi = 1
    }
    else{
        $multi = 0
    }

    try{
        $cmd.CommandText = "INSERT INTO tblColumns (ID,GroupName,DisplayName,InternalName,Type,DefaultValue,Description,Date,Multi,InProd) VALUES('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}')" -f $id,$group,$displayName,$internalName,$type,$defaultValue,$description.Replace("'","''"),$date,$multi,1
        [void]$cmd.ExecuteNonQuery()
    }
    catch{
        $cmd.CommandText = "UPDATE tblColumns Set GroupName = '{0}',DisplayName='{1}',InternalName='{2}',Type='{3}',DefaultValue='{4}',Description='{5}',Date='{6}',Multi='{8}',InProd='{9}' WHERE ID = '{7}'" -f $group, $displayName,$internalName,$type,$defaultValue,$description.Replace("'","''"),$date,$id,$multi,1
        [void]$cmd.ExecuteNonQuery()
    }
    if($type -eq "Choice"){
        $choices = $field.Choices
        foreach($choice in $choices){
            try{
                $cmd.CommandText = "INSERT INTO tblColumnValues (ID, ColumnID,ColumnValue,Date,Duplicates,InProd) VALUES('{0}','{1}','{2}','{3}','{4}','{5}')" -f ($id.ToString()+$choice.Replace("'","''")),$id,$choice.Replace("'","''"),$date,1,1
                [void]$cmd.ExecuteNonQuery()
            }
            catch{
                $cmd.CommandText = "SELECT [Date],[ID],[Duplicates] FROM [Reporting].[dbo].[tblColumnValues] WHERE ID='{0}'" -f ($id.ToString()+$choice.Replace("'","''"))
                $DataSet = New-Object System.Data.DataSet
                $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
                $SqlAdapter.SelectCommand = $cmd
                [void]$SqlAdapter.Fill($DataSet)
                $tbl = $DataSet.Tables
                $rowDate = $tbl.Item(0).Date.ToString("MM/dd/yyyy")
                #$count = $tbl.Item(0).Duplicates
                if($date.ToString() -ne $rowDate){
                    $count = 1
                }
                else{
                    $count++
                }

                $cmd.CommandText = "UPDATE tblColumnValues Set Id='{0}',ColumnID='{1}',ColumnValue='{2}',Date='{3}',Duplicates='{4}',InProd='{5}' WHERE ID='{0}'" -f ($id.ToString()+$choice.Replace("'","''")),$id, $choice.Replace("'","''"),$date,$count,1
                [void]$cmd.ExecuteNonQuery()
            }
        }
    }
}

#endregion

#region Content Types

$contentTypes = $web.ContentTypes | ? {$_.Group -match "Aptar"}

##### Remove data from database

##### Write all content types to datbase
foreach($ct in $contentTypes){
    $ctstring = $ct.Id.ToString()
    $ctguid = [guid]$ctstring.Substring($ctstring.Length-32)
    
    $GroupName = $ct.Group
    $Name = $ct.Name
    $Parent = $ct.Parent.Name
    try{
        $cmd.CommandText = "INSERT INTO tblContentTypes (ID,GroupName,Name,Parent,Date,InProd) VALUES('{0}','{1}','{2}','{3}','{4}','{5}')" -f $ctguid,$GroupName,$Name,$Parent,$date,1        
        [void]$cmd.ExecuteNonQuery()
    }
    catch{
        $cmd.CommandText = "UPDATE tblContentTypes Set ID='{0}',GroupName='{1}',Name='{2}',Parent='{3}',Date='{4}',InProd='{5}' WHERE ID='{0}'" -f $ctguid,$GroupName,$Name,$Parent,$date,1
        [void]$cmd.ExecuteNonQuery()
    }
    $ctFields = $ct.FieldLinks
    foreach($field in $ctFields){
        $id = $field.Id
        try{
            $cmd.CommandText = "INSERT INTO tblColumnToContentType (ID, ColumnId,ContentTypeID,Date,InProd) VALUES('{0}','{1}','{2}','{3}','{4}')" -f ($id.ToString()+$ctguid.ToString()),$id,$ctguid,$date,1
            [void]$cmd.ExecuteNonQuery()
        }
        catch{
            $cmd.CommandText = "UPDATE tblColumnToContentType Set ID='{0}',ColumnId='{1}',ContentTypeID='{2}',Date='{3}',InProd='{4}' WHERE ID='{0}'" -f ($id.ToString()+$ctguid.ToString()),$id,$ctguid,$date,1
            [void]$cmd.ExecuteNonQuery()
        }
    }
}
#endregion

$con.Close()
# Add SharePoint PowerShell Snapin

if ( (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) {
    Add-PSSnapin Microsoft.SharePoint.Powershell
}

#—————————————————————————-
# Delete Field
#—————————————————————————-
function DeleteField([string]$siteUrl, [string]$fieldName) {

    Write-Host “`t`tProcessing Content Types for column:” $fieldName -ForegroundColor Cyan
    $site = Get-SPSite $siteUrl
    $web = $site.RootWeb

    #Delete field from all content types
    foreach($ct in $web.ContentTypes) {
        #$ct.Name
        #if($ct.Name -ne "Policy or Procedure"){

            $fieldInUse = $ct.FieldLinks | Where {$_.Name -eq $fieldName }

            if($fieldInUse) {
                Write-Host “`t`tFound field $fieldName on content type:” $ct.Name -ForegroundColor DarkGreen
                $ct.FieldLinks.Delete($fieldName)
                $ct.Update()
                Write-Host “`t`tRemoved from content type ” $ct.Name -ForegroundColor DarkGreen
            }
        #}
        #else{
        #    Write-Host "Don't clean up Policy or Procedure Content Type"
        #}
    }

    #Delete column from all lists in all sites of a site collection
    $site | Get-SPWeb -Limit all | ForEach-Object {
        Write-Host “`t`tProcessing Lists for column:” $fieldName -ForegroundColor Cyan
        #if($fieldName -ne "Next Review Date"){
           #Specify list which contains the column
            $numberOfLists = $_.Lists.Count
            for($i=0; $i -lt $_.Lists.Count ; $i++) {
            
                #Write-Host “`t`t`tChecking List:” $list.Title -ForegroundColor Yellow
                $list = $_.Lists[$i]

                #Specify column to be deleted
                if($list.Fields.ContainsField($fieldName)) {

                    Write-Host “`t`tFound field $fieldName on List:” $list.Title -ForegroundColor DarkGreen
                    $fieldInList = $list.Fields.GetField($fieldName)

                    if($fieldInList) {

                        if ($fieldInList.Hidden -eq $true) {

                            #Special handling for _hidden columns per
                            #http://sharepointandaspnet.blogspot.com/2013/08/exception-setting-hidden-cannot-change.html
                            $bindingFlags = [Reflection.BindingFlags] "NonPublic,Instance"
                            [System.Type] $type = $fieldInList.GetType()
                            [Reflection.MethodInfo] $mdInfo = $type.GetMethod("SetFieldBoolValue",$bindingFlags)
                            $object = [System.Object] @("CanToggleHidden",$true)
                            $mdInfo.Invoke($fieldInList,$object)
                            $fieldInList.Hidden = $false
                            $fieldInList.AllowDeletion = $true
                            $fieldInList.Update()  
                        }

                         #Allow column to be deleted
                         $fieldInList.AllowDeletion = $true
                         #Delete the column
                         $fieldInList.Delete()
                         #Update the list
                         $list.Update()
                         Write-Host “`t`tRemoved from list ” $list.Title ” on:” $_.URL -ForegroundColor DarkGreen

                    }
                }
            }
        #}
    }

    $web.Dispose()
    $site.Dispose()

}


#SCRIPT VARIABLES TO UPDATE
#$ColumnList = @("(Applies to) Segment","Lifecycle State","Regulatory Standard","Safety / Non-Safety","Security Classification", "Legal Operational Leader", "Legal Project Leader", "Legal Project Name", "Litigation Source", "Aptar Policy Type", "Contract Status" )
#Use Internal Name as Display Name does not appear to find all references, preventing deletionn at site level
#$ColumnList = @("AptarSegment","AptarLCState","AptarRegulatoryStandard","AptarSafetyRelated","AptarSecurityClass", "AptarLegalOpsLead", "AptarLegalProjectLead", "AptarLegalProjectName", "AptarLitigationSource", "AptarPolicyType", "AptarContractStatus" )
$ColumnList = @("Column Name")
$WebApps = @("Content type Hub", "Portal", "MySite Host")
#$WebApps = @("CTHub - 2441", "Collaboration - 21225", "SharePoint - 80", "Publishing - 35231", "MySites - 28962")
#$WebApps = @("MySite Host","SB1 Content type Hub", "SB1 Portal", "SB Records Center", "Site Templates")
#$WebApps = @("Dev Portal", "Dev Records Center", "Site Templates")

foreach ($app in $WebApps)
{
    $webApp = Get-SPWebApplication -Identity $app
    write-host "Web Application:" $webApp.Name -Foregroundcolor Green

    foreach ($site in $webApp.Sites){
        write-host "`tSite:" $site.Url -Foregroundcolor Cyan

        foreach ($field in $ColumnList){
            #Delete the field below
            DeleteField $site.Url $field

        }

       foreach ($field in $ColumnList){
            #Remove the field itself
            if($site.rootWeb.Fields.ContainsField($field)) {

                Write-Host “`t`tRemove site column:” $field -ForegroundColor Yellow
                $site.rootWeb.Fields.Delete($field)

            }
        }        
    }
}
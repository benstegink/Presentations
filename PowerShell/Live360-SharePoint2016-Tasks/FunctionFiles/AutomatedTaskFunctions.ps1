function Add-SPContentType ($weburl,$listname,$contenttype){
    $web = Get-SPWeb $weburl
    $list = $web.Lists[$listname]
    if($list.ContentTypesEnabled -ne $true){
        $list.ContentTypesEnabled = $true
        $list.Update()
    }
    $libct = $list.ContentTypes[$contenttype]
    if($libct -eq $null){
        $ct = $web.AvailableContentTypes[$contenttype]
        if($ct -ne $null){
            [void] $list.ContentTypes.Add($ct)
            $list.Update()
            Write-Host "The Content Type" $contenttype "was succesfully added to the library" $listname "on site" $web.Url -ForegroundColor Green
        }
        else{
            Write-Host "The Content Type" $contenttype "wasn't available on the site" $web.Url "to add to the library" $listname -ForegroundColor Red
        }
    }
    else{
        Write-Host "The Content Type" $contenttype "has already been added to the library" $listname "on site" $web.Url -ForegroundColor Yellow
    }
}

function Publish-SPContentTypeHub {
    param
    (
        [parameter(mandatory=$true)][string]$CTHUrl,
        [parameter(mandatory=$true)][string]$Group
    )
 
    $site = Get-SPSite $CTHUrl
    if(!($site -eq $null))
    {
        $contentTypePublisher = New-Object Microsoft.SharePoint.Taxonomy.ContentTypeSync.ContentTypePublisher ($site)
        $site.RootWeb.ContentTypes | ? {$_.Group -eq $Group} | % {
            $contentTypePublisher.Publish($_)
            write-host "Content type" $_.Name "has been republished" -foregroundcolor Green
        }
    }
}


function Create-SPListView($list,$viewname){
    switch($viewname){
       #***********Project Wish Views***********		
       "Project Documents" {
            $viewTitle = "Project Documents"
            $view = $list.Views[$viewTitle]

            if ($view -eq $null){
                #Columns
                $viewFields = New-Object System.Collections.Specialized.StringCollection
                [void] $viewFields.Add("DocIcon")
                [void] $viewFields.Add("LinkFilename")
                [void] $viewFields.Add("Modified")
                [void] $viewFields.Add("Modified By")

                #View Properties
                $viewQuery = "<OrderBy><FieldRef Name='Modified' Ascending='FALSE' /></OrderBy>
                    <Where><Eq><FieldRef Name='ContentType' /><Value Type='Text'>Project Plan</Value></Eq></Where>"
                $viewRowLimit = 30
                $viewPaged = $true
                $viewDefaultView = $false

                #Create the view in the destination list
                $newview = $list.Views.Add($viewTitle, $viewFields, $viewQuery, $viewRowLimit, $viewPaged, $viewDefaultView )
                Write-Host ("View '" + $viewTitle + "' created in list '" + $list.Title) -ForegroundColor Green
            }
            else{
                $view.ViewFields.DeleteAll()
                $view.Update()
                $view = $list.Views[$viewTitle]
                
                #View Columns
                [void] $view.ViewFields.Add("DocIcon")
                [void] $view.ViewFields.Add("LinkFilename")
                [void] $view.ViewFields.Add("Modified")
                [void] $view.ViewFields.Add("Modified By")

                #View Properties
                $view.Query = "<OrderBy><FieldRef Name='Modified' Ascending='FALSE' /></OrderBy><Where><Eq><FieldRef Name='ContentType' /><Value Type='Text'>Project Plan</Value></Eq></Where>"
                $view.RowLimit = 30 
                $view.Paged = $true
                $view.DefaultView = $false
                
                #Update the existing view in the destination list
                $view.Update()
                Write-Host "$viewtitle view already existed -- updated" -ForegroundColor Yellow
            }
        }

       "Technical Documents"{
            $viewTitle = "Technical Documents"
            $view = $list.Views[$viewTitle]

            if ($view -eq $null){
                #Columns
                $viewFields = New-Object System.Collections.Specialized.StringCollection
                [void] $viewFields.Add("DocIcon")
                [void] $viewFields.Add("LinkFilename")
                [void] $viewFields.Add("Document Type")
                [void] $viewFields.Add("Modified")
                [void] $viewFields.Add("Modified By")

                #View Properties
                $viewQuery = "<OrderBy><FieldRef Name='Modified' Ascending='FALSE' /></OrderBy><Where><Eq><FieldRef Name='ContentType' /><Value Type='Text'>Technical Specifications</Value></Eq></Where>"
                $viewRowLimit = 30
                $viewPaged = $true
                $viewDefaultView = $false

                #Create the view in the destination list
                $newview = $list.Views.Add($viewTitle, $viewFields, $viewQuery, $viewRowLimit, $viewPaged, $viewDefaultView )
                Write-Host ("View '" + $viewTitle + "' created in list '" + $list.Title) -ForegroundColor Green
            }
            else{
                $view.ViewFields.DeleteAll()
                $view.Update()
                $view = $list.Views[$viewTitle]
                
                #View Columns
                [void] $view.ViewFields.Add("DocIcon")
                [void] $view.ViewFields.Add("LinkFilename")
                [void] $view.ViewFields.Add("Document Type")
                [void] $view.ViewFields.Add("Modified")
                [void] $view.ViewFields.Add("Modified By")

                #View Properties
                $viewQuery = "<OrderBy><FieldRef Name='Modified' Ascending='FALSE' /></OrderBy><Where><Eq><FieldRef Name='ContentType' /><Value Type='Text'>Technical Specifications</Value></Eq></Where>"
                $view.RowLimit = 30 
                $view.Paged = $true
                $view.DefaultView = $false
                
                #Update the existing view in the destination list
                $view.Update()
                Write-Host "$viewtitle view already existed -- updated" -ForegroundColor Yellow
            }
        }
        "All Items"{
            $viewTitle = "All Items"
            $view = $list.Views[$viewTitle]

            if ($view -eq $null){
                #Columns
                $viewFields = New-Object System.Collections.Specialized.StringCollection
                [void] $viewFields.Add("LinkTitle")
                [void] $viewFields.Add("AptarWishDescription")
                [void] $viewFields.Add("AptarWishStakeholders")
                [void] $viewFields.Add("AptarWishStatus")
                [void] $viewFields.Add("Modified")

                #View Properties
                $viewQuery = "<OrderBy><FieldRef Name='Modified' Ascending='FALSE' /></OrderBy>"
                $viewRowLimit = 30
                $viewPaged = $true
                $viewDefaultView = $true

                #Create the view in the destination list
                $newview = $list.Views.Add($viewTitle, $viewFields, $viewQuery, $viewRowLimit, $viewPaged, $viewDefaultView )
                ##Write-Host ("View '" + $viewTitle + "' created in list '" + $list.Title)
            }
            else{
                $view.ViewFields.DeleteAll()
                $view.Update()
                $view = $list.Views[$viewTitle]
                
                #View Columns
                [void] $view.viewFields.Add("LinkTitle")
                [void] $view.viewFields.Add("AptarWishDescription")
                [void] $view.viewFields.Add("AptarWishStakeholders")
                [void] $view.viewFields.Add("AptarWishStatus")
                [void] $view.viewFields.Add("Modified")

                #View Properties
                $view.Query = "<OrderBy><FieldRef Name='Modified' Ascending='FALSE' /></OrderBy>"
                $view.RowLimit = 30 
                $view.Paged = $true
                $view.DefaultView = $true
                
                #Update the existing view in the destination list
                $view.Update()
                ##Write-Host "$viewtitle view already existed -- updated"
            }
        }
    }
}
 
#input parameter should be my site url
function ListUPPDisplayOrder($siteUrl){
    Add-Type -Path "C:\program files\common files\microsoft shared\web server extensions\15\isapi\Microsoft.Office.Server.dll"
    $mysite = Get-SPSite $siteUrl
    $context = Get-SPServiceContext $mysite

    $psmManager = [Microsoft.Office.Server.UserProfiles.ProfileSubtypeManager]::Get($context)
    $ps = $psmManager.GetProfileSubtype([Microsoft.Office.Server.UserProfiles.ProfileSubtypeManager]::GetDefaultProfileName([Microsoft.Office.Server.UserProfiles.ProfileType]::User))
    $pspm = $ps.Properties

    $pspm.PropertiesWithSection | ft Name,IsSection,DisplayName,DisplayOrder
    #if you have several profile sub-types, you might want to change the following line and use the name of the desired profile sub-type
}
 
function UPPReorder($configFile,$siteUrl){
 Add-Type -Path "C:\program files\common files\microsoft shared\web server extensions\15\isapi\Microsoft.Office.Server.dll"
 $config = [xml] (Get-Content $configFile)
 $mys = Get-SPSite $siteUrl
 $context = Get-SPServiceContext $mys
 #$upcManager = New-Object Microsoft.Office.Server.UserProfiles.UserProfileConfigManager($context)
 
 $psmManager = [Microsoft.Office.Server.UserProfiles.ProfileSubtypeManager]::Get($context)
 $ps = $psmManager.GetProfileSubtype([Microsoft.Office.Server.UserProfiles.ProfileSubtypeManager]::GetDefaultProfileName([Microsoft.Office.Server.UserProfiles.ProfileType]::User))
 $pspm = $ps.Properties
 
 #if you have several profile sub-types, you might want to change the following line and use the name of the desired profile sub-type
 #$defaultUserProfileSubTypeName = [Microsoft.Office.Server.UserProfiles.ProfileSubtypeManager]::GetDefaultProfileName("User")
 #$profileSubtypePropManager = $upcManager.ProfilePropertyManager.GetProfileSubtypeProperties($defaultUserProfileSubTypeName)
 
 foreach($property in $config.Configuration.Properties.childnodes){
	 $propName = $property.Name
	 if($property.Section -eq "true"){
		 Write-Host "Updating section $propName ..."
		 $pspm.SetDisplayOrderBySectionName($property.Name,$property.Order)
	 }
	 else{
		 Write-Host "Updating property $propName ..."
		 $pspm.SetDisplayOrderByPropertyName($property.Name,$property.Order)
	 }
 }
 $pspm.CommitDisplayOrder()
 #$profileSubtypePropManager.CommitDisplayOrder()
 Write-Host "Finished."
}


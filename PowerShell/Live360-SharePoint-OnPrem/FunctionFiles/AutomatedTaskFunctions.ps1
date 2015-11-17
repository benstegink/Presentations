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
        $site.RootWeb.ContentTypes | ? {$_.Group -match $Group} | % {
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
                [void] $viewFields.Add("LinkTitle")
                [void] $viewFields.Add("AptarWishDescription")
                [void] $viewFields.Add("AptarWishStakeholders")
                [void] $viewFields.Add("AptarWishStatus")
                [void] $viewFields.Add("Modified")

                #View Properties
                $viewQuery = "<OrderBy><FieldRef Name='Modified' Ascending='FALSE' /></OrderBy><Where><Eq><FieldRef Name='AptarWishStatus' /><Value Type='Computed'>Under Review</Value></Eq></Where>"
                $viewRowLimit = 30
                $viewPaged = $true
                $viewDefaultView = $false

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
                $view.Query = "<OrderBy><FieldRef Name='Modified' Ascending='FALSE' /></OrderBy><Where><Eq><FieldRef Name='AptarWishStatus' /><Value Type='Computed'>Under Review</Value></Eq></Where>"
                $view.RowLimit = 30 
                $view.Paged = $true
                $view.DefaultView = $false
                
                #Update the existing view in the destination list
                $view.Update()
                ##Write-Host "$viewtitle view already existed -- updated"
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
                [void] $view.ViewFields.Add("DocIcon")
                [void] $view.ViewFields.Add("LinkFilename")
                [void] $view.ViewFields.Add("Document Type")
                [void] $view.ViewFields.Add("Modified")
                [void] $view.ViewFields.Add("Modified By")

                #View Properties
                $viewQuery = "<OrderBy><FieldRef Name='Modified' Ascending='FALSE' /></OrderBy><Where><Eq><FieldRef Name='ContentType' /><Value Type='Text'>Technical Specifications</Value></Eq></Where>"
                $view.RowLimit = 30 
                $view.Paged = $true
                $view.DefaultView = $true
                
                #Update the existing view in the destination list
                $view.Update()
                ##Write-Host "$viewtitle view already existed -- updated"
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
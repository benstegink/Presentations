function Provision-TeamSite($url,$requester){

	. D:\SP2013\Scripts\Provisioning\Common\Provisioning-Functions.ps1
	. D:\SP2013\Scripts\Provisioning\Common\Deploy-ContentTypePacks.ps1
    . D:\SP2013\Scripts\Provisioning\Common\Nintex-Commands.ps1
    . D:\SP2013\Scripts\Provisioning\Common\DocAve-Functions.ps1

	$scriptversion = "1.0.7"
    $siteTemplateVersion = "TeamSite v2"
	$web = Get-SPWeb $url
	#Evnironment can be: "SB1", "SB2", "DEV", "TEST", "PROD"
	$env = "SB1"

	$web.AllProperties["ProvisioningScriptVersion"] = $scriptversion
    $web.AllProperties["SiteTemplateVersion"] = $siteTemplateVersion
    $web.AllProperties["SiteRequester"] = $requester
	$web.Update()

    $docaveControlServiceAddress = '172.22.42.227'
    $docaveControlServicePort = 14000
    $docaveControlServiceUser = 'admin'
    $docaveControlServicePwd = 'xGf!?y9PaQ+pTYK'

    #Global Variables
    #Security Groups
    $gadAdmins = "AD Security Group"
    $legalTeam = "AD Security Group"

    #DocAve Module
    $docaveModulePath = "D:\Program Files\AvePoint\DocAve6\Shell\DocAveModules\DocAveModule\Cmdlet.dll"
            
    #Nintex Workflows
    $publishingWF = "D:\SP2013\Scripts\Provisioning\Common\Default.nwf"
    $publishingWFContracts = "D:\SP2013\Scripts\Provisioning\Common\Contracts_Default.nwf"
    $publishingWFInit = "D:\SP2013\Scripts\Provisioning\Common\MakeFinalInitial.nwf"
    $removeFinalDocWF = "D:\SP2013\Scripts\Provisioning\Common\RemoveDefault.nwf"
    $removeFinalDocWFInit = "D:\SP2013\Scripts\Provisioning\Common\RemoveFinalInitial.nwf"
    $signatureWF = "D:\SP2013\Scripts\Provisioning\Common\SignatureWorkflow.nwf" #1.0.7
    #End Global Variables

	switch($env){
		"SB1" {
			$farmadmin = "sb1-spadmin"
			$farminstall = "sb1-spinstall"
			$isFarmadmins = "AD Security Group"

            #Provisioning List
            $ProvisioningListUrl = "http://sb1-intranet/provisioning"

            #DocAve Variables
            $docaveFarmName = "Farm(sb1-servername:SP2013_CONFIG)"

            #Nintex Workflows
            $nintexWFE = "servername.domain.local"
            $wfServiceAccount = "domain\sb1-nintexWsorkflow"
		}
		"DEV" {
            $farmadmin = "dev-spadmin"
            $farminstall = "dev-spinstal"
			$isFarmadmins = "AD Security Group"
            
            #Provisioning List
            $ProvisioningListUrl = "http://dev-intranet/provisioning"

            #DocAve Variables
            $docaveFarmName = "Farm(dev-serername:SP2013_CONFIG)"
            
            #Nintex Workflows
            $nintexWFE = "servername.domain.local"
            $wfServiceAccount = "domain\dev-nintexWorkflow"       
		}
		"TEST" {
            $farmadmin = "test-spadmin"
            $farminstall = "test-spinstall"
			$isFarmadmins = "AD Security Group"
            
            #Provisioning List
            $ProvisioningListUrl = "http://test-intranet/provisioning"
            
            #DocAve Variables
            $docaveFarmName = "Farm(test-servername:SP2013_CONFIG)"
            
            #Nintex Workflows
            $nintexWFE = "servername.domain.loccal"
            $wfServiceAccount = "domain\test-nintextWorkflow" 
		}
		"PROD" {
            $farmadmin = "spadmin"
            $farminstall = "spinstall"
			$isFarmadmins = "AD Security Group"

            #Provisioning List
            $ProvisioningListUrl = "http://intranet/provisioning"

            #DocAve Variables
            $docaveFarmName = "Farm(servernameL:SP2013_CONFIG)"
            
            #Nintex Workflows
            $nintexWFE = "servername.domain.local"
            $wfServiceAccount = "domain\nintextWorkflow"  
		}
	}

	$web.Dispose()

	#Create SharePoint Permission Levels
	Create-SharePointPermissionLevel "Site Owner" $url
    Create-SharePointPermissionLevel "Manage Lists" $url #1.07

	#Update SharePoint Permission Levels
	Update-SharePointPermissionsLevel "Edit" $url
    Update-SharePointPermissionsLevel "Contribute" $url
	Update-SharePointPermissionsLevel "Read" $url

	#Delete Unused Permission Levels
	#Delete-SharePointPermissionLevel "View Only" $url
	#Delete-SharePointPermissionLevel "Contribute" $url

	#Create SharePoint Groups and Assign Permissions
	Create-SharePointGroup "IS Admin" $url "Full Control" $farmadmin
	Create-SharePointGroup "Site Owner" $url "Site Owner" $farmadmin
    Create-SharePointGroup "Legal" $url "" $farmadmin

	#Add Groups to Security Quick Launch
	$web = Get-SPWeb $url
	Add-GroupToSecurityQL $url ($web.Title + " IS Admin")
	Add-GroupToSecurityQL $url ($web.Title + " Site Owner")

	#Rename SharePoitn Groups
	Rename-SharePointGroup ($web.Title + " Members") ($web.Title + " Edit")
	Rename-SharePointGroup ($web.Title + " Visitors") ($web.Title + " Read")

	#Update SharePoint Group Properties
	Update-SharePointGroup ($web.Title + " Read") $url

    #Update SharePoing Group Owners
    Update-SharePointGroupOwner -groupname "Edit" -groupowner "Site Owner" -url $url
    Update-SharePointGroupOwner -groupname "Read" -groupowner "Site Owner" -url $url

	$web.Dispose()

	#Remove SharePoint Security Groups
	$web = Get-SPWeb $url
	Remove-SharePointGroup ($web.Title + " Owners") $url
	Remove-SharePointGroup "Excel Services Viewers" $url

	#Add Users to SharePoint Groups
	Add-UsersToSPGroup $url $isFarmadmins "IS Admin"
    Add-UsersToSPGroup $url $gadAdmins "IS Admin"
    Add-UsersToSPGroup $url $legalTeam "Legal Team"

    #Add Users to Site Onwers Group
    $secondaryContact = $web.AllProperties["GA_SecondarySiteCollectionContact"]
    $primaryContact = $web.AllProperties["GA_PrimarySiteCollectionContact"]
    Add-UsersToSPGroup $url $primaryContact "Site Owner"
    Add-UsersToSPGroup $url $secondaryContact "Site Owner"
	Remove-UsersFromSPGroup $url $farmadmin ($web.Title + " Read")
	$web.Dispose()

	#Remove Service Accounts from Groups and Site
	Remove-UserFromSite $url $farminstall

    #Add Site Collection Administrators
    Add-SiteCollectionAdmin -url $url -user $wfServiceAccount

	#Enable/Disable Access Requests
    #Enable: Set RequestAccessEmail to an email address
    #Disable: Set RequestAccessEmail to $null
	$web = Get-SPWeb $url
	#$web.Permissions.RequestAccessEmail = $null
    $web.Permissions.RequestAccessEmail = "user@domain.com"
	$web.Update()
	$web.Dispose()
	#Activate required Team Site Features
    Activate-TeamSiteFeatures -url $url -farmAdminName $farmadmin -nintexWFE $nintexWFE
	
	#Add Indexed Properties from the site
    if($env -eq "PROD"){
	    Add-IndexedSiteProperty "GA_Segment" $url 
	    Add-IndexedSiteProperty "GA_Department" $url         
    }
    else{
	    Add-IndexedSiteProperty ("GA_" + $env + "_Segment") $url 
	    Add-IndexedSiteProperty ("GA_" + $env + "_Department") $url 
    }

	#Disable Offline Access to Document Library
	Disable-OfflineAccess $web.Lists["Team Documents"]
	Disable-OfflineAccess $web.Lists["Contracts"]
    Disable-OfflineAccess $web.Lists["Published Documents"] #1.0.7
    Disable-OfflineAccess $web.Lists["Staging Library"] #1.0.7

	#Set to Open in Forms Dialog
	$web = Get-SPWeb $url
	Open-FormsDialog $web.Lists["Team Documents"]
	Open-FormsDialog $web.Lists["Contacts"]
	Open-FormsDialog $web.Lists["Contracts"]
	Open-FormsDialog $web.Lists["Tasks"]
	Open-FormsDialog $web.Lists["Calendar"]
	Open-FormsDialog $web.Lists["Contacts"]
	Open-FormsDialog $web.Lists["Published Documents"]
	Open-FormsDialog $web.Lists["Staging Library"] #1.0.7
	Open-FormsDialog $web.Lists["Signed Contracts"]
	Open-FormsDialog $web.Lists["Useful Links"]
	$web.Dispose()

	#Set Quick Nav Headers to Null - #1.07
	$web = Get-SPWeb $url
    $newUrl = "javascript:void(0);"
	$web.Navigation.QuickLaunch | ForEach-Object {
		if(($_.Title -match "Working Libraries") -Or ($_.Title -match "Lists") -Or($_.Title -match "Final Libraries")) {
            #Write-Host "Updating" $_.Title "URL from" $_.Url "to" $newUrl
			$_.Url = "$newUrl"
			$_.Update()
		}
	}

    #Set up useful links - #1.07
    Add-UsefulLink $web.Url "http://intranet/Shared%20Documents/User%20Guide.docx" "Basic User Guide" "Contains basic instructions for using the Intranet, based on Microsoft SharePoint 2013."

    $web.Dispose()

	#show week numbers on Calendars
	#Show-CalendarWeekNumbers $web

    #Set Publishing Library Properties
    Set-FinalLibrary -url $url -libName "Published Documents"
    Set-FinalLibrary -url $url -libName "Signed Contracts"
    Set-FinalLibrary -url $url -libName "Staging Library" #1.0.7

    #Set Library Types
    Set-LibraryType -url $url -libName "Published Documents" -libraryType "Publishing"
    Set-LibraryType -url $url -libName "Staging Library" -libraryType "Publishing" #1.0.7
    Set-LibraryType -url $url -libName "Signed Contracts" -libraryType "Contracts"
    Set-LibraryType -url $url -libName "Contracts" -libraryType "Contracts"
    Set-LibraryType -url $url -libName "Team Documents" -libraryType "TeamDocuments"

	#**********Add ContentTypes**********
	#Contracts and Signed Contracts Library
	Add-ContentTypes $url "Contracts" "ContractContentTypes" $false
	Add-ContentTypes $url "Signed Contracts" "ContractContentTypes" $false

	#Team Documents
	Add-ContentTypes $url "Team Documents" "CoreContentTypes" $false

	#Published Documents
	Add-ContentTypes $url "Published Documents" "CoreContentTypes" $false
    Replicate-SPLibraryContentTypes -srcListName "Published Documents" -destListName "Staging Library" -url $url
    #Add-ContentTypes $url "Staging Library" "CoreContentTypes" $false #1.0.7

	#**********Department Specific Sections**********
    $web = Get-SPWeb $url
    if($env -eq "PROD"){
        $dept = $web.AllProperties["GA_Department"]
    }
    else{
        $dept = $web.AllProperties["GA_" + $env + "_Department"]
    }
    if($dept -ne $null -and $dept -ne "None"){
        $dept = $dept.SubString(0,$dept.IndexOf(";"))
	    if($dept -eq "Legal"){
		    #Team Documents
		    Add-ContentTypes $url "Team Documents" "LegalContentTypes" $true
		    Create-Views $url "Team Documents" "LegalViews" $true
		    #Published Documents
		    Add-ContentTypes $url "Published Documents" "LegalContentTypes" $true
		    Create-Views $url "Published Documents" "LegalPublishedViews" $true
		    Replicate-SPLibraryContentTypes -srcListName "Published Documents" -destListName "Staging Library" -url $url
            #Add-ContentTypes $url "Staging Library" "LegalContentTypes" $true #1.0.7
		    #Create-Views $url "Staging Library" "LegalPublishedViews" $true #1.0.7
	    }
        else{
        	#Team Documents
	        Add-ContentTypes $url "Team Documents" "CoreContentTypes" $true
	        #Published Documents
	        Add-ContentTypes $url "Published Documents" "CoreContentTypes" $true
            Replicate-SPLibraryContentTypes -srcListName "Published Documents" -destListName "Staging Library" -url $url
            #Add-ContentTypes $url "Staging Library" "CoreContentTypes" $true #1.0.7
        }
    }
    else{
        #Team Documents
	    Add-ContentTypes $url "Team Documents" "CoreContentTypes" $true
	    #Published Documents
	    Add-ContentTypes $url "Published Documents" "CoreContentTypes" $true
        Replicate-SPLibraryContentTypes -srcListName "Published Documents" -destListName "Staging Library" -url $url
        #Add-ContentTypes $url "Staging Library" "CoreContentTypes" $true #1.0.7
    }
    $web.Dispose()

	#**********Create Views**********
	#Team Documents
	Create-Views $url "Team Documents" "CoreViews"
    #Published Documents
    Create-Views $url "Published Documents" "CoreViews"
    Create-Views $url "Staging Library" "CoreViews"
	#Contracts and Signed Contracts Library
	Create-Views $url "Contracts" "ContractViews"
	Create-Views $url "Signed Contracts" "ContractViews"


	#Set Site Collection Documents Permissions
	$web = Get-SPWeb $url
    Break-LibraryInheritance $web.Lists["Contracts"]
    Break-LibraryInheritance $web.Lists["Published Documents"]
    Break-LibraryInheritance $web.Lists["Signed Contracts"]
    Break-LibraryInheritance $web.Lists["Tasks"] #1.07
	$web.Dispose()
    #Contracts
    Update-LibraryPermissions $url "Legal" "Contracts" "Edit" $false
	#Published Documents
    Update-LibraryPermissions $url "Edit" "Published Documents" "Read" $true
    Update-LibraryPermissions $url "Site Owner" "Published Documents" "Read" $false
    Update-LibraryPermissions $url "Read" "Published Documents" "Read" $false
    Update-LibraryPermissions $url "IS Admin" "Published Documents" "Full Control" $false

    #1.07 - Need this in order to add tasks to timeline.
    Update-LibraryPermissions $url "Site Owner" "Tasks" "Manage Lists" $false #1.07

    #Signed Contracts
    Update-LibraryPermissions $url "Edit" "Signed Contracts" "Read" $true
    Update-LibraryPermissions $url "Site Owner" "Signed Contracts" "Read" $false
    Update-LibraryPermissions $url "IS Admin" "Signed Contracts" "Full Control" $false
    Update-LibraryPermissions $url "Read" "Signed Contracts" "Read" $false
    Update-LibraryPermissions $url "Legal" "Signed Contracts" "Read" $false

    #Enable Theme
	Activate-Theme -url $url

	#Update Navigation
	Create-AdminLink $url

	#Create Search Center
	Create-SearchCenter $url

	#Create Search Navigation
	Create-SearchNavigation $url
    Create-SearchNavigation -url ($url.TrimEnd("/") + "/search")

    #Enable Theme on Search Center
    Activate-Theme -url ($url.TrimEnd("/") + "/search")

    #Hide Document Category Field
    Hide-DocumentCategory -url $url

    #Hide Content Type Field on Contract Binders
    Remove-FolderContractBinders -url $url

    #Set Defaults
    Set-FieldDefaults -url $url -env $env -listName "Contracts"
    Set-FieldDefaults -url $url -env $env -listName "Team Documents"

    #Deploy Nintex Workflows
    #Publish-NintexWorkflow -url $url -listName "Team Documents" -WorkflowFile $testWF
    Publish-NintexWorkflow -url $url -listName "Team Documents" -WorkflowFile $publishingWF -prePendLibraryName $true
    Publish-NintexWorkflow -url $url -listName "Team Documents" -WorkflowFile $publishingWFInit -prePendLibraryName $true
    Publish-NintexWorkflow -url $url -listName "Contracts" -WorkflowFile $publishingWFContracts -prePendLibraryName $True -WorkflowName "Default"
    Publish-NintexWorkflow -url $url -listName "Contracts" -WorkflowFile $publishingWFInit -prePendLibraryName $true
    Publish-NintexWorkflow -url $url -listName "Published Documents" -WorkflowFile $removeFinalDocWF -prePendLibraryName $true
    Publish-NintexWorkflow -url $url -listName "Published Documents" -WorkflowFile $removeFinalDocWFInit -prePendLibraryName $true
    Publish-NintexWorkflow -url $url -listName "Signed Contracts" -WorkflowFile $removeFinalDocWF -prePendLibraryName $true
    Publish-NintexWorkflow -url $url -listName "Signed Contracts" -WorkflowFile $removeFinalDocWFInit -prePendLibraryName $true
    Publish-NintexWorkflow -url $url -listName "Staging Library" -WorkflowFile $signatureWF -prePendLibraryName $true #1.0.7

    #1.07 Set Permissions for Workflow lists
    $web = Get-SPWeb $url
        $wfTaskList =  $web.Lists["Workflow Tasks"]
        $wfHistList = $web.Lists["NintexWorkflowHistory"]
        Break-LibraryInheritance $wfTaskList  #1.07
        Break-LibraryInheritance $wfHistList #1.07
        $account = $web.EnsureUser("NT AUTHORITY\authenticated users")
        $role = $web.RoleDefinitions["Edit"]
        $assignment = New-Object Microsoft.SharePoint.SPRoleAssignment($account)
        $assignment.RoleDefinitionBindings.Add($role)
        $wfTaskList.RoleAssignments.Add($assignment)
        $wfHistList.RoleAssignments.Add($assignment)
        $wfTaskList.Update()
        $wfHistList.Update()
    $web.Update()
    $web.Dispose()

    #Run Baseline Security Report
    Enable-WebAuditing -url $url
    $filePath = Export-DocAveSecurityReport -url $url -farmName $docaveFarmName -ControlServiceAddress $docaveControlServiceAddress -ControlServicePort $docaveControlServicePort -ControlServiceUser $docaveControlServiceUser -ControlServicePwd $docaveControlServicePwd
    Upload-FileToDocLibrary -siteUrl $ProvisioningListUrl -libraryName "Security Reports" -filePath $filePath -overwrite $true
	Remove-Item $filePath -Force

    #Add to Site List
    Add-SiteToProvisioningList -url $url -ProvisioningListURL $ProvisioningListUrl -env $env

	$web.Dispose()
}
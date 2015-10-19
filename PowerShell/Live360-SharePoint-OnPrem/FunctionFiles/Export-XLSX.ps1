function Export-XLSX{
#requires -Version 2
# requires .Net Version 3.0

<#
	.SYNOPSIS
		This script converts object properties into a serie of strings and saves the strings into a worksheet contained in a Excel XLSX workbook.
		(This script will by referenced with the name: Export-XLSX)

	.DESCRIPTION
		(This scrißpt will by referenced with the name: Export-XLSX)
	
		These script cmdlet creates a Excel XLSX workbook file and stores the data of the objects that you submit in a worksheet within the workbook.
		Each object is represented as a row of cells (line) in a worksheet within the workbook.
		The row consists of a number of Text typed worksheet cells. Each cell will contain the value of a property of the object (property column).
		Each property is converted into its string representation and stored as type of text inline into the Excel worksheet XML.
		
		By default, the first cell row (line) of the worksheet represents the "column headers".
		The cells in this row contains the names of all the properties of the first object.
			
		Additional rows of cells (lines) of the worksheet consist of the current processed object property values, converted to their string representation.
		The object types and properties of the additional rows can differ from the first Object!
		It is up to you to take care that the column header row matches the object property colums.
		If you input different object types to this script you can drop the header row by using the NoHeader switch parameter.
		
		You can use this Function to create real Excel XLSX spreadsheets without having Microsoft Excel installed!		
		
		The .XLSX file created by this script follows the Open Packaging Conventions as outlined in the Office Open XML (OOXML)
		standard ECMA-376 and by ISO and IEC (as ISO/IEC 29500).

		NOTE:
		Do not format objects before sending them to this script.
		If you do, the format properties are represented in the Excel file, instead of the properties of the original objects.
		To export only selected properties of an object, use the Select-Object cmdlet.

	.PARAMETER Append
		Adds a worksheet (and data) to the end of the specified workbook file.
		Without this parameter, this script replaces the file without warning.

	.PARAMETER Force
		Overwrites the file specified in path without prompting.
		
	.PARAMETER InputObject
		Specifies the objects to export into the worksheet cells.
		Enter a variable that contains the objects or type a command or expression that gets the objects.
		You can also pipe objects to this script.
		
	.PARAMETER NoClobber
		Do not overwrite (replace the contents) of an existing file.
		By default, if a file exists in the specified path, this script will overwrite the file without warning.
		
	.PARAMETER  NoHeader
		Omits the "column header" row from the worksheet.		
		
	.PARAMETER Path
		Specifies the path to the Excel XLSX output file. This parameter is required.
		
	.PARAMETER  WorkSheetName
		The Name of the new Excel worksheet to create
		Worksheet Names must be unique to an Excel workbook.
		If you provide an allready existing worksheet name an Warning is generated and an automatic name is used.
		If you dont provide an worksheet name an unique name is autmaticaly generate with the pattern Table + number (eg: Table21)		

	.EXAMPLE
		PS C:\> Get-ChildItem $env:windir | Select-Object Mode,LastWriteTime,Length,Name  | Export-XLSX -Path 'D:\temp\PSExcel.xlsx' -WorkSheetName 'Files'
		
		Creates a new .xlsx workbook file in the Path D:\temp\PSExcel.xlsx and a new worksheet inside the worbook with the name Files
		Stores the data collected by Get-ChildItem in the new worksheet
		(This script is referenced with the name: Export-XLSX)

	.EXAMPLE
		PS C:\> Get-Process | Select-Object Handles,Id,ProcessName | Export-XLSX -Path 'D:\temp\PSExcel.xlsx' -WorkSheetName 'Processes' -Append

		Appends a new worksheet with the name Processes to the existing .xlsx workbook file in the Path D:\temp\PSExcel.xlsx
		Stores the data collected by Get-Process in the new worksheet
		(This script is referenced with the name: Export-XLSX)
		
	.INPUTS
		PSObject

	.OUTPUTS
		Void

	.NOTES
		Author PowerShell:  Peter Kriegel, Germany http://www.admin-source.de
		Version: 1.0.0 23.August.2013
		Bug fixed with double header lines
		Version: 1.0.1 12.September.2013
		Added support for relative Pathes in Parameter -Path
		(suggested by xrajj. thank you!)
		Version: 1.0.2 07.November.2013

	.LINK
		SpreadsheetML or XLSX
		http://officeopenxml.com/anatomyofOOXML-xlsx.php

	.LINK
		Read and write Open XML files (MS Office 2007)
		http://www.developerfusion.com/article/6170/read-and-write-open-xml-files-ms-office-2007/
#>

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [System.Management.Automation.PSObject]$InputObject,
    [Parameter(Mandatory=$true, Position=0)]
    [Alias('PSPath','FilePath')]
    [System.String]$Path,
    [Switch]$NoClobber,
	[Switch]$Force,
	[Switch]$NoHeader,
	[Switch]$Append,
	[String]$WorkSheetName
	)

# begin the begin block of the main script	
Begin {
 
	# loading WindowsBase.dll with the System.IO.Packaging namespace
	# C:\Program Files\Reference Assemblies\Microsoft\Framework\v3.0\WindowsBase.dll
	 $Null = [Reflection.Assembly]::LoadWithPartialName("WindowsBase")
 
	 # [Reflection.Assembly]::LoadWithPartialName throws no exception so we test if assembly is loaded
	 $AssemblyLoaded = $False
	 ForEach ($asm in [AppDomain]::CurrentDomain.GetAssemblies()) {
		If ($asm.GetName().Name -eq 'WindowsBase') {
			$AssemblyLoaded = $True
		}
	}
	
	# if assembly could not be loaded throw ErrorRecord
	If(-not $AssemblyLoaded) {
		# create custom ErrorRecord
		$message = "Could not load 'WindowsBase.dll' assembly from .NET Framework 3.0!"
		$exception = New-Object System.IO.FileNotFoundException $message
		$errorID = 'AssemblyFileNotFound'
		$errorCategory = [Management.Automation.ErrorCategory]::NotInstalled
		$target = 'C:\Program Files\Reference Assemblies\Microsoft\Framework\v3.0\WindowsBase.dll'
		$errorRecord = New-Object Management.Automation.ErrorRecord $exception,$errorID,$errorCategory,$target
		# throw terminating error
		$PSCmdlet.ThrowTerminatingError($errorRecord)
		# leave script
		return
	}
 
 
#region	declare (helper) functions

	Function Test-FileLocked {
	# Some file action needs exclusive access by the calling process, so Windows will lock access to a file.
	# This Function can detect if a file is locked or not
	# If PassThru is not given then the function returns $True if the File is locked Else it returns $False
	# If PassThru is given then the function returns a Management.Automation.ErrorRecord Object if the File is locked Else it returns $Null
	# the file could become locked the very next millisecond after this check by any other process!
	# Peter Kriegel 22.August.2013 Version 1.0.0

		param(
			[Parameter(Mandatory=$True,
				Position=0,
				ValueFromPipeline=$True,
				ValueFromPipelinebyPropertyName=$True
			)]
			[String]$Path,
			[System.IO.FileAccess]$FileAccessMode = [System.IO.FileAccess]::Read,
			[Switch]$PassThru
			
		)
	   
		If(Test-Path $Path) {
			$FileInfo = Get-Item $Path
		} Else {
			Return $False
		}
		
	    try
	    {
	        $Stream = $FileInfo.Open([System.IO.FileMode]::Open, $FileAccessMode, [System.IO.FileShare]::None)
			
	    }
	    catch [System.IO.IOException]
	    {
	        #the file is unavailable because it is:
	        #still being written to or being processed by another thread
	        #or does not exist (has already been processed)
			If($PassThru.IsPresent) {
		        #Return $_.Exception
						
				$message = $_.Exception.Message
				$exception = $_.Exception
				$errorID = 'FileIsLocked'
				$errorCategory = [Management.Automation.ErrorCategory]::OpenError
				$target = $Path
				$errorRecord = New-Object Management.Automation.ErrorRecord $exception, $errorID,$errorCategory,$target
				Return $errorRecord

			} Else {
		        Return $True
		    }
			
	    }
	    finally
	    {
	        if ($stream){
				$stream.Close()
			}
	    }

	    #file is not locked
		If($PassThru.IsPresent) {
			Return $Null
		} Else {
			$False
		}
	}

#endregion declare (helper) functions

#region declare XLSX functions

	Function Add-XLSXWorkSheet {
	<#
		.SYNOPSIS
			Function to append an new empty Excel worksheet to an existing Excel .xlsx workbook

		.DESCRIPTION
			Function to append an new empty Excel worksheet to an existing Excel .xlsx workbook

		.PARAMETER  Path
			Path to the existing Excel .xlsx workbook

		.PARAMETER  Name
			The Name of the new Excel worksheet to create
			Worksheet Names must be unique to an Excel workbook.
			If you provide an allready existing worksheet name an warning is generated and a automatic name is used.
			If you dont provide an worksheet name an unique name is autmaticaly generate with the pattern Table + number (eg: Table21)

		.EXAMPLE
			PS C:\> Add-XLSXWorkSheet -Path 'D:\temp\PSExcel.xlsx' -Name "Willy"
			
			Adds a new worksheet with the Name Willy to the Excel workbook stored in path 'D:\temp\PSExcel.xlsx'

		.EXAMPLE
			PS C:\> Add-XLSXWorkSheet -Path 'D:\temp\PSExcel.xlsx'
			
			Adds a new worksheet with the automatic generate name to the Excel workbook stored in path 'D:\temp\PSExcel.xlsx'

		.INPUTS
			System.String,System.String

		.OUTPUTS
			PSObject with Properties: 
				Uri # The Uri of the new generated worksheet in the XLSX package
				WorkbookRelationID # XLSX package relationship ID to the from Workbook to the worksheet
				Name # Name of the worksheet 
				WorkbookPath # Path to the Excel workbook (XLSX package) which holds the worksheet

		.NOTES
			Author PowerShell:  Peter Kriegel, Germany http://www.admin-source.de
			Version: 1.0.0 14.August.2013
	#>
		
		[CmdletBinding()]
		param(
			[Parameter(Mandatory=$True,
				Position=0,
				ValueFromPipeline=$True,
				ValueFromPipelinebyPropertyName=$True
			)]
			[String]$Path,
			[String]$Name
		)

		Begin {

			# create worksheet XML document

			# create empty XML Document
			$New_Worksheet_xml = New-Object System.Xml.XmlDocument

	        # Obtain a reference to the root node, and then add the XML declaration.
	        $XmlDeclaration = $New_Worksheet_xml.CreateXmlDeclaration("1.0", "UTF-8", "yes")
	        $Null = $New_Worksheet_xml.InsertBefore($XmlDeclaration, $New_Worksheet_xml.DocumentElement)

	        # Create and append the worksheet node to the document.
	        $workSheetElement = $New_Worksheet_xml.CreateElement("worksheet")
			# add the Excel related office open xml namespaces to the XML document
	        $Null = $workSheetElement.SetAttribute("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main")
	        $Null = $workSheetElement.SetAttribute("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
	        $Null = $New_Worksheet_xml.AppendChild($workSheetElement)

	        # Create and append the sheetData node to the worksheet node.
	        $Null = $New_Worksheet_xml.DocumentElement.AppendChild($New_Worksheet_xml.CreateElement("sheetData"))

		} # end begin block

	Process {

			# test if File is locked
			If($ErrorRecord = Test-FileLocked 'D:\temp\PSExcel.xlsx' -PassThru){
				$PSCmdlet.WriteError($ErrorRecord)
				return
			}
			
			Try {
				# test if the file could be accessed
				# generate an ErrorRecord Object which is automaticly translated in other languages by the Microsoft mechanism 
				$Null = Get-Item -Path $Path -ErrorAction stop
			} Catch {
				# we dont want to show the ErrorRecord Object in the $Error list 
				$Error.RemoveAt(0)
				# recreate an ErrorRecord Object with the invocation info from this function from catched translated ErrorRecord Object
				$NewError = New-Object System.Management.Automation.ErrorRecord -ArgumentList $_.Exception,$_.FullyQualifiedErrorId,$_.CategoryInfo.Category,$_.TargetObject
				# throw the ErrorRecord Object
				$PSCmdlet.WriteError($NewError)
				# leave Function
				Return
			}
			
			# open Excel .XLSX package file
			Try {
				
				$exPkg = [System.IO.Packaging.Package]::Open($Path, [System.IO.FileMode]::Open)
			} catch {
				$_
				Return
			}

			# find /xl/workbook.xml
			ForEach ($Part in $exPkg.GetParts()) {
				# remember workbook.xml 
				IF($Part.ContentType -eq "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml" -or $Part.Uri.OriginalString -eq "/xl/workbook.xml") {
					$WorkBookPart = $Part
					# found workbook exit foreach loop
					break
				}
			}

			If(-not $WorkBookPart) {
				Write-Error "Excel Workbook not found in : $Path"
				$exPkg.Close()
				return
			}
			
			# get all relationships of Workbook part
			$WorkBookRels = $WorkBookPart.GetRelationships()
			
			$WorkBookRelIds = [System.Collections.ArrayList]@()
			$WorkSheetPartNames = [System.Collections.ArrayList]@()
			
			ForEach($Rel in $WorkBookRels) {
				
				# collect workbook relationship IDs in a Arraylist
				# to easely find a new unique relationship ID
				$Null = $WorkBookRelIds.Add($Rel.ID)

				# collect workbook related worksheet names in an Arraylist
				# to easely find a new unique sheet name
				If($Rel.RelationshipType -like '*worksheet*' ) {
					$WorkSheetName = Split-Path $Rel.TargetUri.ToString() -Leaf
					$Null = $WorkSheetPartNames.Add($WorkSheetName)
				}
			}
			
			# find a new unused relationship ID
			# relationship ID have the pattern rID + Number (eg: reID1, rID2, rID3 ...)
			$IdCounter = 0 # counter for relationship IDs
			$NewWorkBookRelId = '' # Variable to hold the new found relationship ID
			Do{
				$IdCounter++
				If(-not ($WorkBookRelIds -contains "rId$IdCounter")){
					# $WorkBookRelIds does not contain the rID + Number
					# so we have found an unused rID + Number; create it
					$NewWorkBookRelId = "rId$IdCounter"
				}
			} while($NewWorkBookRelId -eq '')

			# find new unused worksheet part name
			# worksheet in the package have names with the pattern Sheet + number + .xml
			$WorksheetCounter = 0 # counter for worksheet numbers
			$NewWorkSheetPartName = '' # Variable to hold the new found worksheet name
			Do{
				$WorksheetCounter++
				If(-not ($WorkSheetPartNames -contains "sheet$WorksheetCounter.xml")){
					# $WorkSheetPartNames does not contain the worksheet name
					# so we have found an unused sheet + Number + .xml; create it
					$NewWorkSheetPartName = "sheet$WorksheetCounter.xml"
				}
			} while($NewWorkSheetPartName -eq '')
			
			# Excel allows only unique WorkSheet names in a workbook
			# test if worksheet name already exist in workbook
			$WorkbookWorksheetNames = [System.Collections.ArrayList]@()

			# open the workbook.xml
			$WorkBookXmlDoc = New-Object System.Xml.XmlDocument
			# load XML document from package part stream
			$WorkBookXmlDoc.Load($WorkBookPart.GetStream([System.IO.FileMode]::Open,[System.IO.FileAccess]::Read))

			# read all Sheet elements from workbook
			ForEach ($Element in $WorkBookXmlDoc.documentElement.Item("sheets").get_ChildNodes()) {
				# collect sheet names in Arraylist
				$Null = $WorkbookWorksheetNames.Add($Element.Name)
			}
			
			# test if a given worksheet $Name allready exist in workbook
			$DuplicateName = ''
			If(-not [String]::IsNullOrEmpty($Name)){
				If($WorkbookWorksheetNames -Contains $Name) {
					# save old given name to show in warning message
					$DuplicateName = $Name
					# empty name to create a new one
					$Name = ''
				}
			} 
			
			# If the user has not given a worksheet $Name or the name allready exist 
			# we try to use the automatic created name with the pattern Table + Number
			If([String]::IsNullOrEmpty($Name)){
				$WorkSheetNameCounter = 0
				$Name = "Table$WorkSheetNameCounter"
				# while automatic created Name is used in workbook.xml we create a new name
				While($WorkbookWorksheetNames -Contains $Name) {
					$WorkSheetNameCounter++
					$Name = "Table$WorkSheetNameCounter"
				}
				If(-not [String]::IsNullOrEmpty($DuplicateName)){
					Write-Warning "Worksheetname '$DuplicateName' allready exist!`nUsing automatically generated name: $Name"
				}
			}

	#region Create worksheet part
			
			# create URI for worksheet package part
			$Uri_xl_worksheets_sheet_xml = New-Object System.Uri -ArgumentList ("/xl/worksheets/$NewWorkSheetPartName", [System.UriKind]::Relative)
			# create worksheet part
			$Part_xl_worksheets_sheet_xml = $exPkg.CreatePart($Uri_xl_worksheets_sheet_xml, "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml")
			# get writeable stream from part 
			$dest = $part_xl_worksheets_sheet_xml.GetStream([System.IO.FileMode]::Create,[System.IO.FileAccess]::Write)
			# write $New_Worksheet_xml XML document to part stream
			$New_Worksheet_xml.Save($dest)
			
			# create workbook to worksheet relationship
			$Null = $WorkBookPart.CreateRelationship($Uri_xl_worksheets_sheet_xml, [System.IO.Packaging.TargetMode]::Internal, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet", $NewWorkBookRelId)
			
	#endregion 	Create worksheet part

	#region edit xl\workbook.xml
					
			# edit the xl\workbook.xml
			
			# create empty XML Document
			$WorkBookXmlDoc = New-Object System.Xml.XmlDocument
			# load XML document from package part stream
			$WorkBookXmlDoc.Load($WorkBookPart.GetStream([System.IO.FileMode]::Open,[System.IO.FileAccess]::Read))
					
			# create a new XML Node for the sheet 
			$WorkBookXmlSheetNode = $WorkBookXmlDoc.CreateElement('sheet', $WorkBookXmlDoc.DocumentElement.NamespaceURI)
	        $Null = $WorkBookXmlSheetNode.SetAttribute('name',$Name)
	        $Null = $WorkBookXmlSheetNode.SetAttribute('sheetId',$IdCounter)
			# try to create the ID Attribute with the r: Namespace (xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships") 
			$NamespaceR = $WorkBookXmlDoc.DocumentElement.GetNamespaceOfPrefix("r")
			If($NamespaceR) {
	        	$Null = $WorkBookXmlSheetNode.SetAttribute('id',$NamespaceR,$NewWorkBookRelId)
			} Else {
				$Null = $WorkBookXmlSheetNode.SetAttribute('id',$NewWorkBookRelId)
			}
			
			# add the new sheet node to XML document
			$Null = $WorkBookXmlDoc.DocumentElement.Item("sheets").AppendChild($WorkBookXmlSheetNode)
		
			# Save back the edited XML Document to package part stream
			$WorkBookXmlDoc.Save($WorkBookPart.GetStream([System.IO.FileMode]::Open,[System.IO.FileAccess]::Write))

	#endregion edit xl\workbook.xml		
			
			# close main package (flush all changes to disk)
			$exPkg.Close()
			
			# return datas of new created worksheet
			New-Object -TypeName PsObject -Property @{Uri = $Uri_xl_worksheets_sheet_xml;
													WorkbookRelationID = $NewWorkBookRelId;
													Name = $Name;
													WorkbookPath = $Path
													}
			
		} # end Process block
		
		End { 
			} # end End block
	}

	Function New-XLSXWorkBook {
	<#
		.SYNOPSIS
			Function to create a new empty Excel .xlsx workbook (XLSX package)

		.DESCRIPTION
			Function to create a new empty Excel .xlsx workbook (XLSX package)
			
			This creates an empty Excel workbook without any worksheet!
			Worksheets are mandatory for .xlsx Files! So you have to add at least one worksheet!

		.PARAMETER  Path
			Path to the Excel .xlsx workbook to create
			
		.PARAMETER  NoClobber
			Do not overwrite (replace the contents) of an existing file.
			By default, if a file exists in the specified path, New-XLSXWorkBook overwrites the file without warning.
			
		.PARAMETER Force
			Overwrites the file specified in path without prompting.		

		.EXAMPLE
			PS C:\> New-XLSXWorkBook -Path 'D:\temp\PSExcel.xlsx'
			
			Creates the new empty Excel .xlsx workbook in the Path 'D:\temp\PSExcel.xlsx' 

		.OUTPUTS
			System.IO.FileInfo

		.NOTES
			Author PowerShell:  Peter Kriegel, Germany http://www.admin-source.de
			Version: 1.0.0 14.August.2013
	#>

		param(
			[Parameter(Mandatory=$True,
				Position=0,
				ValueFromPipeline=$True,
				ValueFromPipelinebyPropertyName=$True
			)]
			[String]$Path,
			[ValidateNotNull()]
			[Switch]$NoClobber,
			[Switch]$Force
		)

		Begin {
				
			# create the Workbook.xml part XML document
			
			# create empty XML Document
			$xl_Workbook_xml = New-Object System.Xml.XmlDocument

	        # Obtain a reference to the root node, and then add the XML declaration.
	        $XmlDeclaration = $xl_Workbook_xml.CreateXmlDeclaration("1.0", "UTF-8", "yes")
	        $Null = $xl_Workbook_xml.InsertBefore($XmlDeclaration, $xl_Workbook_xml.DocumentElement)

	        # Create and append the workbook node to the document.
	        $workBookElement = $xl_Workbook_xml.CreateElement("workbook")
			# add the office open xml namespaces to the XML document
	        $Null = $workBookElement.SetAttribute("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main")
	        $Null = $workBookElement.SetAttribute("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
	        $Null = $xl_Workbook_xml.AppendChild($workBookElement)

	        # Create and append the sheets node to the workBook node.
	        $Null = $xl_Workbook_xml.DocumentElement.AppendChild($xl_Workbook_xml.CreateElement("sheets"))

		} # end begin block
		
		Process {	
			
			# set the file extension to xlsx
			$Path = [System.IO.Path]::ChangeExtension($Path,'xlsx')
			
			Try {
				# test if the file could be created
				# generate an ErrorRecord Object which is automaticly translated in other languages by the Microsoft mechanism 
				Out-File -InputObject "" -FilePath $Path -NoClobber:$NoClobber.IsPresent -Force:$Force.IsPresent -ErrorAction stop
				Remove-Item $Path -Force
			} Catch {
				# we dont want to show the ErrorRecord Object in the $Error list 
				$Error.RemoveAt(0)
				# recreate an ErrorRecord Object with the invocation info from this function from catched translated ErrorRecord Object
				$NewError = New-Object System.Management.Automation.ErrorRecord -ArgumentList $_.Exception,$_.FullyQualifiedErrorId,$_.CategoryInfo.Category,$_.TargetObject
				# throw the ErrorRecord Object
				$PSCmdlet.WriteError($NewError)
				# leave Function
				Return
			}
			
			Try {
				# create the main package on disk with filemode create
				$exPkg = [System.IO.Packaging.Package]::Open($Path, [System.IO.FileMode]::Create)
			} Catch {
				$_
				return
			}
			
			# create URI for workbook.xml package part
			$Uri_xl_workbook_xml = New-Object System.Uri -ArgumentList ("/xl/workbook.xml", [System.UriKind]::Relative)
			# create workbook.xml part
			$Part_xl_workbook_xml = $exPkg.CreatePart($Uri_xl_workbook_xml, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml")
			# get writeable stream from workbook.xml part 
			$dest = $part_xl_workbook_xml.GetStream([System.IO.FileMode]::Create,[System.IO.FileAccess]::Write)
			# write workbook.xml XML document to part stream
			$xl_workbook_xml.Save($dest)

			# create package general main relationships
			$Null = $exPkg.CreateRelationship($Uri_xl_workbook_xml, [System.IO.Packaging.TargetMode]::Internal, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument", "rId1")
			
			# close main package
			$exPkg.Close()

			# return the FileInfo for the created XLSX file
			Return Get-Item $Path

		} # end Process block
		
		End {
		} # end End block
	}

	Function Export-WorkSheet {
	<#
		.SYNOPSIS
			Function to fill an empty Excel worksheet with datas

		.DESCRIPTION
			Function to fill an empty Excel worksheet with datas
			
			The Export-WorkSheet function fills an Excel worksheet with the propertys of the objects that you submit.
			Each object is represented as a line or row of the worksheet.
			The row consists of a number of Text typed worksheet cells. Each cell will contain the value of a Property of the object.
			Each property is converted into its string representation and stored as type of text inline into the Excel worksheet XML.
			You can use this Function to create real Excel XLSX spreadsheets without having Microsoft Excel installed!

			By default, the first cell row (line) of the worksheet represents the "column headers".
			The cells in this row contains the names of all the properties of the first object.
			
			Additional cell rows (lines) of the worksheet consist of the property values converted to their string representation of each object.
			
			NOTE: Do not format objects before sending them to the Export-WorkSheet function.
			If you do, the format properties are represented in the worksheet,
			instead of the properties of the original objects.
			To export only selected properties of an object, use the Select-Object cmdlet.

		.PARAMETER  Path
			Path to the existing Excel .xlsx workbook

		.PARAMETER  WorksheetUri
			System.Uri Object which points to a existing worksheet inside the e Excel workbook
			
		.PARAMETER InputObject
			Specifies the objects to export into the worksheet cells.
			Enter a variable that contains the objects or type a command or expression that gets the objects.
			You can also pipe objects to Export-XLSX.

		.PARAMETER  NoHeader
			Omits the "column header" row from the worksheet.
			
		.EXAMPLE
			PS C:\> Get-Something -ParameterA 'One value' -ParameterB 32

		.EXAMPLE
			PS C:\> Get-Something 'One value' 32

		.INPUTS
			System.String,System.Int32

		.OUTPUTS
			System.String

		.NOTES
			Author PowerShell:  Peter Kriegel, Germany http://www.admin-source.de
			Version: 1.0.0 14.August.2013

		.LINK
			about_functions_advanced

		.LINK
			about_comment_based_help

	#>
		
		[CmdletBinding()]
		param(
			[Parameter(Mandatory=$True,
				Position=0,
				ValueFromPipeline=$True,
				ValueFromPipelinebyPropertyName=$True
			)]
			[System.String]$Path,
			###########################
			[Parameter(Mandatory=$True,
				Position=1,
				ValueFromPipeline=$True,
				ValueFromPipelinebyPropertyName=$True
			)]
			[System.Uri]$WorksheetUri,
			###########################
			[Parameter(Mandatory=$true,
				Position=1,
				ValueFromPipeline=$true,
				ValueFromPipelineByPropertyName=$true
			)]
	    	[System.Management.Automation.PSObject]$InputObject,
			###########################
			[Switch]$NoHeader
			###########################
		)
		
		Begin {

			$exPkg = [System.IO.Packaging.Package]::Open($Path, [System.IO.FileMode]::Open)
			
			$WorkSheetPart = $exPkg.GetPart($WorksheetUri)
			
			# open worksheet xml
			$WorkSheetXmlDoc = New-Object System.Xml.XmlDocument
			# load XML document from package part stream
			$WorkSheetXmlDoc.Load($WorkSheetPart.GetStream([System.IO.FileMode]::Open,[System.IO.FileAccess]::Read))
			
			$HeaderWritten = $False
		}

		Process {

			# create the value property if the InputObject is an value type
			# this property creates the column with the name of the value type
			If($InputObject.GetType().Name -match 'byte|short|int32|long|sbyte|ushort|uint32|ulong|float|double|decimal|string') {
				Add-Member -InputObject $InputObject -MemberType NoteProperty -Name ($InputObject.GetType().Name) -Value $InputObject
			}

			# Create XML Workseet Rows with data type of Text: t="inlineStr"
			#<row>
			#	<c t="inlineStr">
			#		<is>
			#			<t>Data is here</t>
			#		</is>
			#	</c>
			#</row>

			If((-not $HeaderWritten) -and (-not $NoHeader.IsPresent) ){
				
				$RowNode = $WorkSheetXmlDoc.CreateElement('row', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
			
				ForEach($Prop in $InputObject.psobject.Properties) {
					$CellNode = $WorkSheetXmlDoc.CreateElement('c', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
					$Null = $CellNode.SetAttribute('t',"inlineStr")
					$Null = $RowNode.AppendChild($CellNode)
					
					$CellNodeIs = $WorkSheetXmlDoc.CreateElement('is', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
					$Null = $CellNode.AppendChild($CellNodeIs)
					
					$CellNodeIsT = $WorkSheetXmlDoc.CreateElement('t', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
					$CellNodeIsT.InnerText = [String]$Prop.Name
					$Null = $CellNodeIs.AppendChild($CellNodeIsT)
					
					$Null = $WorkSheetXmlDoc.DocumentElement.Item("sheetData").AppendChild($RowNode)	
				}
				
				$HeaderWritten = $True
			}

			$RowNode = $WorkSheetXmlDoc.CreateElement('row', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)

			ForEach($Prop in $InputObject.psobject.Properties) {
				$CellNode = $WorkSheetXmlDoc.CreateElement('c', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
				$Null = $CellNode.SetAttribute('t',"inlineStr")
				$Null = $RowNode.AppendChild($CellNode)
				
				$CellNodeIs = $WorkSheetXmlDoc.CreateElement('is', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
				$Null = $CellNode.AppendChild($CellNodeIs)
				
				$CellNodeIsT = $WorkSheetXmlDoc.CreateElement('t', $WorkSheetXmlDoc.DocumentElement.Item("sheetData").NamespaceURI)
				$CellNodeIsT.InnerText = [String]$Prop.Value
				$Null = $CellNodeIs.AppendChild($CellNodeIsT)
				
				$Null = $WorkSheetXmlDoc.DocumentElement.Item("sheetData").AppendChild($RowNode)

			} # end ForEach $Prop

		} # end Process block

		End {
			$WorkSheetXmlDoc.Save($WorkSheetPart.GetStream([System.IO.FileMode]::Open,[System.IO.FileAccess]::Write))
			$exPkg.Close()
		} # end End block
	}
	
#endregion declare XLSX functions		

		# Resolve Path if it is a relative Path like .\ or .\my\file
		$Path = [System.IO.Path]::GetFullPath($Path)
		
		# set the file extension to xlsx
		$Path = [System.IO.Path]::ChangeExtension($Path,'xlsx')
						
		# Only if the file exist and append is present we use  test if we can create/overwrite the file (even if -Append is present!)
		If((Test-Path $Path) -and $Append.IsPresent ) {
			# file exist and append is present
			# add the new worksheet to the existing workbook
			$WorkSheet = Add-XLSXWorkSheet -Name $WorkSheetName -Path $Path
		} Else {
			# append is not given or the file does not exist so we create a new file 
			Try {
				# test for errors
				# we misuse Out-File cmdlet to test if the file could be created or overridden and to create better errorrecords then [System.IO.Packaging.Package]::Open creates. 
				# Out-File generates an ErrorRecord Object which is automaticly translated in other languages by the Microsoft mechanism 
				Out-File -InputObject "" -FilePath $Path -NoClobber:$NoClobber.IsPresent -Force:$Force.IsPresent -ErrorAction stop
				Remove-Item $Path -Force
			} Catch {
				# we dont want to show the original Out-File ErrorRecord Object in the $Error list 
				$Error.RemoveAt(0)
				# recreate an ErrorRecord Object with the invocation info from this script from the catched ErrorRecord Object
				$NewError = New-Object System.Management.Automation.ErrorRecord -ArgumentList $_.Exception,$_.FullyQualifiedErrorId,$_.CategoryInfo.Category,$_.TargetObject
				# throw the ErrorRecord Object
				$PSCmdlet.WriteError($NewError)
				# leave script
				Return
			}
			
			# Out-File has not thrown a error
			# we can create the real XLSX workbook
			$Null = New-XLSXWorkBook -Path $Path -Force:$Force.IsPresent -NoClobber:$NoClobber.IsPresent
			# add the new worksheet to the new workbook
			$WorkSheet = Add-XLSXWorkSheet -Name $WorkSheetName -Path $Path
		}
		
		$HeaderWritten = $False
		
} # end of the Begin block of main script

# begin the process block of main script
Process {
	
	Export-WorkSheet -InputObject $InputObject -NoHeader:($NoHeader.IsPresent -or $HeaderWritten) -Path $Path -WorksheetUri $WorkSheet.Uri
	$HeaderWritten = $True
		
} # end of the Process block  of main script

# begin the end block of main script 
End {
} # end of the End block  of main script

}
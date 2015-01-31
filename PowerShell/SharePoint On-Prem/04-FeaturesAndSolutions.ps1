#Features and Solutions
Get-SPFeature
Get-SPFeature -url http://intranet

Get-Command *-SPFeature


Get-SPSolution

Get-Command *-SPSolution


#Download All Solutions for Backup/DR
#Saves all .WSP Files to the directory specified below
$wspPath = "C:\SharePointSolutions"
New-Item $wspPath -type directory
(Get-SPFarm).Solutions | ForEach-Object{$var = $wspPath + "\" + $_.Name; $_.SolutionFile.SaveAs($var)}
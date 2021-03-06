#requires -Version 2
#Requires –PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
<#

.SYNOPSIS
Get SamAccountName

.DESCRIPTION
Get SamAccountName

FEATURES
- load list of emails from CSV table;
- filter and compare of the list of emails with Exchange list of existing mailbox;
- get SamAccountName for each existing mailbox;
- save list of SamAccountName to text file without separator's;
- this script is writed for Exchange Server 2013;

KNOWNPROBLEMS
- none;

.PARAMETER
Input parameters are not supported. Please use environment variables on begin of script in block.

.OUTPUTS
Text file.

.EXAMPLE
C:\> Get-SamAccountName.ps1

.LINK
http://www.michalzobec.cz/

.NOTES
Get SamAccountName
(c) 2017-2018 Michal Zobec, ZOBEC Consulting. All Rights Reserved.  
web: www.michalzobec.cz, mail: michal@zobec.net  
License: Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)  
https://creativecommons.org/licenses/by-sa/4.0/

.HISTORY
version 17.10.25.1;
	* init version;
version 18.01.02.1;
    * public version on github.com;
version 18.01.02.2;
    * added require snapin;
    * added script header;
#>

Set-StrictMode -Version Latest
$ScriptDir = (split-path $myinvocation.mycommand.path)
$CsvFile = $ScriptDir + "\example.csv"
$OutFile = $ScriptDir + "\example.txt"


if (Test-Path $CsvFile) {
    Write-Host "file exist"
    Write-Host "$CsvFile"
    Write-Host ""
    $CsvList = Import-Csv $CsvFile -Delimiter ";"
}
else {
    Write-Host "file not exist"
    Write-Host "$CsvFile"
    Write-Host ""
    break
}

# load Exchange 2013 Management SnapIn
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$output = $CsvList.mail | Get-Mailbox | Select-Object samaccountname
$output = $output -replace "@{SamAccountName=", ""
$output = $output -replace "}", ""
$output = [regex]::Replace($output, "`n", " ", "Singleline")
$output | Out-File $OutFile

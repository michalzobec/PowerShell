cls
Set-StrictMode -Version Latest
$ScriptDir = (split-path $myinvocation.mycommand.path)
$CsvFile = $ScriptDir + "\example.csv"
$outFile = $ScriptDir + "\example.txt"


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
$output | Out-File $outFile

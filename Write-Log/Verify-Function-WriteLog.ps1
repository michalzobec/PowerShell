#Requires -Version 4
Set-StrictMode -Version 4

<#
.SYNOPSIS
    Verify Function Write Log
    (c) 2019 ZOBEC Consulting, Michal Zobec. All Rights Reserved.
    Licensed under Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

.DESCRIPTION
    Script for verification of running of function for writing of log file in plain/text file format.
    Second role of this file is example file how to use this function.

.OUTPUTS
    Log file.

.EXAMPLE
    C:\> Verify-Function-WriteLog.ps1

.NOTES
    Twitter: @michalzobec
    Blog   : http://www.michalzobec.cz

.LINK
    http://www.michalzobec.cz

.LINK
    http://www.zobecconsulting.cz

#>

#********************************************
#* Definition of variables
#********************************************
#region Definition of variables
# script root variable
$dirScriptRoot = (Split-Path $myinvocation.MyCommand.Path)
# log directory
$dirLog = $dirScriptRoot + "\logs\"
# log date format
$LogDate = Get-Date -Format "yyyyMMdd.HHmm"
# definition of LogFile
$LogFile = $dirLog + "Verify-Function-WriteLog-log-$LogDate.txt"
#endregion
#********************************************

#********************************************
#* External function WriteLog
#********************************************
#region External function WriteLog
$fileFunctionWriteLog = $dirScriptRoot + "\lib\Function-WriteLog.ps1"
if (!(Test-Path -Path $fileFunctionWriteLog)) {
    throw "$fileFunctionWriteLog is not valid. Please provide a valid path to the $fileFunctionWriteLog file."
    break
}
Write-Host "Initialing function WriteLog"
. $fileFunctionWriteLog
#endregion
#********************************************

#region Testing function WriteLog
Write-Host "Testing function WriteLog."
Write-Log -LogFile $LogFile -Message "Write log message without definition of level."
Write-Log -LogFile $LogFile -Message "Write log message with definition of level INFO." -Level INFO
Write-Log -LogFile $LogFile -Message "Write log message with definition of level WARN." -Level WARN
Write-Log -LogFile $LogFile -Message "Write log message with definition of level ERROR." -Level ERROR
Write-Log -LogFile $LogFile -Message "Write log message with definition of level FATAL." -Level FATAL
Write-Log -LogFile $LogFile -Message "Write log message with definition of level DEBUG." -Level DEBUG
Write-Host "Test of function WriteLog was finished."
#endregion
#********************************************

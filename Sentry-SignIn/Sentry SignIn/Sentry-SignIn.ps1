#Requires -Version 5
Set-StrictMode -Version 5

<#
.SYNOPSIS
    Sentry SignIn (NirSoft WinLogOnView Wrapper)
    version 23.01.02.121559
    (c) 2021-2023 Michal Zobec. All Rights Reserved.

.DESCRIPTION
    Runs Sentry SignIn daily.

.OUTPUTS
    Log file and report file only.

.EXAMPLE
    C:\> Sentry-SignIn.cmd

.NOTES
    Twitter: @michalzobec
    Blog   : http://www.michalzobec.cz

.LINK
    http://www.michalzobec.cz

#>

#-------------------------------------------------------------------------

#region logging function
# script name
$ScriptName = "Sentry SignIn"
# script version
$ScriptVersion = "23.01.02.121559"
$CopyRightYearFrom = "2021"
$CopyRightYearTo = "2023"
#endregion


#region logging function
Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False,
            HelpMessage = "Select log level.")]
        [ValidateSet("INFO", "WARN", "ERROR", "FATAL", "DEBUG")]
        [String]
        $Level = "INFO",

        [Parameter(Mandatory = $True,
            HelpMessage = "Information text to logfile.")]
        [string]
        $Message,

        [Parameter(Mandatory = $False,
            HelpMessage = "Logfilename and path.")]
        [string]
        $LogFile
    )

    $Stamp = Get-Date -Format "yyyy\/MM\/dd HH:mm:ss.fff"
    $Line = "[$Stamp] [$Level] $Message"
    If ($LogFile) {
        Add-Content $LogFile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}

$LogDate = Get-Date -Format "yyyyMMdd-HHmm"
$ReportDate = Get-Date -Format "yyyyMMdd-HHmm"
$ScriptDir = (Split-Path $myinvocation.MyCommand.Path)
$ScriptLogDir = $env:ProgramData + "\sentry-signin"
if (!(Test-Path $ScriptLogDir -PathType Container)) {
    Write-Warning "Log directory is not exist. Creating."
    New-Item $ScriptLogDir -ItemType Directory
} else {
    Write-Host "Log directory is exist."
}
$LogFile = $ScriptLogDir + "\Sentry-SignIn-log-$LogDate.txt"
#endregion

#region variables
# External configuration file
$ConfigurationFileName = "Sentry-SignIn-Config.ps1"
# Main binary file
$WinLogOnViewFile = $ScriptDir + "\bin\WinLogOnView.exe"
#endregion

Write-Log -LogFile $LogFile -Level INFO -Message "#######################################################"
Write-Log -LogFile $LogFile -Level INFO -Message "$ScriptName, version $ScriptVersion"
Write-Log -LogFile $LogFile -Level INFO -Message "Copyright (c) $CopyRightYearFrom-$CopyRightYearTo Michal Zobec, ZOBEC Consulting. All Rights Reserved."
Write-Log -LogFile $LogFile -Level INFO -Message "Script execution started"
Write-Host "$ScriptName, version $ScriptVersion"
Write-Host "(c) $CopyRightYearFrom-$CopyRightYearTo Michal Zobec, ZOBEC Consulting. All Rights Reserved."
Write-Host "Script execution started"

######
# Verification and load external configuration file
$CfgFilePath = $ScriptDir + "\config\$ConfigurationFileName"
if (!(Test-Path $CfgFilePath)) {
    Write-Warning "File $ConfigurationFileName is required for run of this script! Exiting."
    Write-Log -LogFile $LogFile -Message "  File $ConfigurationFileName is required for run of this script! Exiting." -Level ERROR
    exit
}
Write-Log -LogFile $LogFile -Level DEBUG -Message "Configuration file: '$ConfigurationFileName'"
Write-Log -LogFile $LogFile -Level DEBUG -Message "Configuration file path: '$CfgFilePath'"
. $CfgFilePath
######

#region variables
$ReportFileHTML = $ReportDir + "\Sentry-SignIn-report-$ReportDate.html"
$ReportFileCSV = $ReportDir + "\Sentry-SignIn-report-$ReportDate.csv"
#endregion

Write-Log -LogFile $LogFile -Level DEBUG -Message "ScriptLogDir path: '$ScriptLogDir'"
Write-Log -LogFile $LogFile -Level DEBUG -Message "Log file path: '$LogFile'"
Write-Log -LogFile $LogFile -Level DEBUG -Message "ReportDir path: '$ReportDir'"
Write-Log -LogFile $LogFile -Level DEBUG -Message "HTML Report file path: '$ReportFileHTML'"
Write-Log -LogFile $LogFile -Level DEBUG -Message "CSV Report file path: '$ReportFileCSV'"
Write-Log -LogFile $LogFile -Level DEBUG -Message "Main executable file path: '$WinLogOnViewFile'"

#region Check-IsElevated
# load script with function
Write-Log -LogFile $LogFile -Level DEBUG -Message "Calling shared script Check-IsElevated ..."
Write-Log -LogFile $LogFile -Level DEBUG -Message "Script path: '$ScriptDir\lib\Check-IsElevated.ps1'"
. $ScriptDir\lib\Check-IsElevated.ps1
# call function
if (-not(Check-IsElevated)) {
    Write-Host "Please run this script as an administrator." -ForegroundColor Red
    Write-Log -LogFile $LogFile -Level ERROR -Message "Administrator permission is missing."
    Write-Log -LogFile $LogFile -Level INFO -Message "Exiting."
    exit
}
#endregion

#region generate html report
Write-Log -LogFile $LogFile -Level INFO -Message "Generating of the HTML report"
$RunExec1 = Start-Process -FilePath "$WinLogOnViewFile" -ArgumentList "/shtml ""$ReportFileHTML"" /sort ""Logon Time""" -NoNewWindow -Wait -PassThru
if ($RunExec1.ExitCode -ne 0) {
    Write-Host "Generating of the report was failed with error code: $($RunExec1.ExitCode)." -ForegroundColor Red
    Write-Log -LogFile $LogFile -Level ERROR -Message "Generating of the HTML report was failed with error code: $($RunExec1.ExitCode)."
    Write-Log -LogFile $LogFile -Level INFO -Message "Exiting."
    exit
}
Write-Log -LogFile $LogFile -Level INFO -Message "HTML Report was generated"
#endregion

#region generate csv report
Write-Log -LogFile $LogFile -Level INFO -Message "Generating of the CSV report"
$RunExec2 = Start-Process -FilePath "$WinLogOnViewFile" -ArgumentList "/scomma ""$ReportFileCSV"" /sort ""Logon Time""" -NoNewWindow -Wait -PassThru
if ($RunExec2.ExitCode -ne 0) {
    Write-Host "Generating of the report was failed with error code: $($RunExec2.ExitCode)." -ForegroundColor Red
    Write-Log -LogFile $LogFile -Level ERROR -Message "Generating of the CSV report was failed with error code: $($RunExec2.ExitCode)."
    Write-Log -LogFile $LogFile -Level INFO -Message "Exiting."
    exit
}
Write-Log -LogFile $LogFile -Level INFO -Message "CSV Report was generated"
#endregion

Write-Log -LogFile $LogFile -Level INFO -Message "Script execution completed"
Write-Log -LogFile $LogFile -Level INFO -Message "#######################################################"

Write-Host "Script execution completed"

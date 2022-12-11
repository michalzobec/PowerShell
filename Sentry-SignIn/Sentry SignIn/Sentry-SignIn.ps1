#Requires -Version 5
Set-StrictMode -Version 5

<#
.SYNOPSIS
    Sentry SignIn (NirSoft WinLogOnView Wrapper)
    version 22.12.09.143459
    (c) 2022 Michal Zobec. All Rights Reserved.

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
$ScriptVersion = "22.12.09.143459"
$CopyRightYearFrom = "2021"
$CopyRightYearTo = "2022"
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

$LogDate = Get-Date -Format "yyyyMMddHHmmss"
$ScriptDir = (Split-Path $myinvocation.MyCommand.Path)
$ScriptLogDir = $ScriptDir + "\logs"
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
$ReportDate = Get-Date -Format "yyyyMMdd-HHmm"
$ReportFile = $ReportDir + "\Sentry-SignIn-report-$ReportDate.html"
#endregion

Write-Log -LogFile $LogFile -Level DEBUG -Message "ScriptLogDir path: '$ScriptLogDir'"
Write-Log -LogFile $LogFile -Level DEBUG -Message "Log file path: '$LogFile'"
Write-Log -LogFile $LogFile -Level DEBUG -Message "ReportDir path: '$ReportDir'"
Write-Log -LogFile $LogFile -Level DEBUG -Message "Report file path: '$ReportFile'"
Write-Log -LogFile $LogFile -Level DEBUG -Message "Main executable file path: '$WinLogOnViewFile'"
#region execute
Write-Log -LogFile $LogFile -Level INFO -Message "Generating of the report"
Start-Process -FilePath "$WinLogOnViewFile" -ArgumentList "/shtml ""$ReportFile"" /sort ""Logon Time""" -NoNewWindow -Wait
Write-Log -LogFile $LogFile -Level INFO -Message "Report was generated"
#endregion

Write-Log -LogFile $LogFile -Level INFO -Message "Script execution completed"
Write-Log -LogFile $LogFile -Level INFO -Message "#######################################################"

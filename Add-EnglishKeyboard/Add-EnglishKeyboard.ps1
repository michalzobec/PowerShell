#Requires -RunAsAdministrator
#Requires -Version 5
Set-StrictMode -Version 5

<#
.SYNOPSIS
    ZOBEC Consulting
    Add English Keyboard (Commandline Tool)
    (c) 2018-2019 ZOBEC Consulting, Michal Zobec. All Rights Reserved.
    Licensed under [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/)

.DESCRIPTION
    For single run configure and start Windows Time Service with defined time (NTP) servers.
    This script is a part of Enterprise System Image (ESI).

.OUTPUTS
    Log file & text output.

.EXAMPLE
    C:\> Add-EnglishKeyboard.ps1

.NOTES
    Twitter: @michalzobec
    Blog   : http://www.michalzobec.cz

.LINK
    http://www.michalzobec.cz

.LINK
    http://www.zobecconsulting.cz

.LINK
About this script on my Blog in Czech
http://zob.ec/esibuild

.LINK
Documentation (ReadMe)
https://github.com/michalzobec/esi-build/blob/master/readme.md

.LINK
Release Notes (ChangeLog)
https://github.com/michalzobec/esi-build/blob/master/changelog.md

#>

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

$LogDate = Get-Date -Format "yyyyMMdd"
$ScriptDir = (Split-Path $myinvocation.MyCommand.Path)
$LogFile = $ScriptDir + "\Add-EnglishKeyboard-log-$LogDate.txt"
#endregion

Write-Log -LogFile $LogFile -Level INFO -Message "##################################"
Write-Log -LogFile $LogFile -Level INFO -Message "### Script was started         ###"
Write-Log -LogFile $LogFile -Level INFO -Message "##################################"

############################
# Add EN-US Keyboard
############################
Write-Log -LogFile $LogFile -Level INFO -Message "Add EN-US Keyboard"
$langs = Get-WinUserLanguageList
$langs.Add("en-US")
Set-WinUserLanguageList $langs -Force

Write-Log -LogFile $LogFile -Level INFO -Message "##################################"
Write-Log -LogFile $LogFile -Level INFO -Message "### Script execution completed ###"
Write-Log -LogFile $LogFile -Level INFO -Message "##################################"

############################
# end section
############################

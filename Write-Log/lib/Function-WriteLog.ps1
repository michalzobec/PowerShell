#Requires -Version 4
Set-StrictMode -Version 4

<#
.SYNOPSIS
    Function Write Log
    (c) 2017-2019 ZOBEC Consulting, Michal Zobec. All Rights Reserved.
    Version: 1907.0 (19.07.29.033159)

.DESCRIPTION
    Script function for writing of log file in plain/text file format.

.OUTPUTS
    Log file.

.EXAMPLE
    C:\> Write-Log -LogFile $LogFile -Message "Write log message without definition of level."

.EXAMPLE
    C:\> Write-Log -LogFile $LogFile -Message "Write log message with definition of level INFO." -Level INFO

.EXAMPLE
    C:\> Write-Log -LogFile $LogFile -Message "Write log message with definition of level ERROR." -Level ERROR

.NOTES
    web: www.michalzobec.cz, mail: michal@zobec.net  
    GitHub repository http://zob.ec/getsystemreport
    License: [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/)
    Twitter: @michalzobec
    Blog   : http://www.michalzobec.cz

.LINK
    http://www.michalzobec.cz

.LINK
    http://www.zobecconsulting.cz

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
            HelpMessage = "Information or error message to logfile.")]
        [string]
        $Message,

        [Parameter(Mandatory = $True,
            HelpMessage = "Logfilename and path.")]
        [string]
        $LogFile
    )

    $Stamp = Get-Date -Format "yyyy\/MM\/dd HH:mm:ss.fff"
    $Line = "[$Stamp] [$Level] $Message"
    Add-Content $LogFile -Value $Line
}

#region Check configuration variables
try {
    Get-Variable dirScriptRoot, dirLog, LogFile, LogDate -Scope Global -ErrorAction Stop | Out-Null
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Warning $_
    Write-Warning "Please define variables dirScriptRoot, dirLog, LogFile, LogDate."
    break
}
#endregion

#region Check if log dir exist
if (!(Test-Path -path "$dirLog")) {
    Write-Host "Directory dirLog not found, creating it."
    New-Item -Path $dirLog -ItemType Directory -Force | Out-Null
}
#endregion

#Requires -Version 5
#Requires -RunAsAdministrator
Set-StrictMode -Version 5

<#
.SYNOPSIS
    ZOBEC Consulting
    Set Windows Time Service (Commandline Tool)
    (c) 2018-2019 ZOBEC Consulting, Michal Zobec. All Rights Reserved.
    Licensed under [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/)

.DESCRIPTION
    For single run configure and start Windows Time Service with defined time (NTP) servers.
    This script is a part of Enterprise System Image (ESI).

.OUTPUTS
    Log file & text output.

.EXAMPLE
    C:\> Set-WindowsTimeService.ps1

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
$LogFile = $ScriptDir + "\Set-WindowsTimeService-log-$LogDate.txt"
#endregion

Write-Log -LogFile $LogFile -Level INFO -Message "##################################"
Write-Log -LogFile $LogFile -Level INFO -Message "### Script was started         ###"
Write-Log -LogFile $LogFile -Level INFO -Message "##################################"

############################
# section windows services
############################

# variables
# list of ntp servers
$PeerList = "tik.cesnet.cz tak.cesnet.cz ntp.nic.cz"

Write-Host "Stopping service w32time"
Write-Log -LogFile $LogFile -Level INFO -Message "Stopping service w32time"
Stop-Service -Name w32time -Force

Write-Host "Changing settings of service w32time"
Write-Log -LogFile $LogFile -Level INFO -Message "Changing settings of service w32time"
Set-Service -Name w32time -StartupType Automatic

Write-Host "Configuring list of ntp servers"
Write-Log -LogFile $LogFile -Level INFO -Message "Configuring list of ntp servers"
Start-Process -FilePath "$Env:SystemRoot\system32\w32tm.exe" -ArgumentList "/config /syncfromflags:manual /manualpeerlist:`"$PeerList`""

Write-Host "Starting service w32time"
Write-Log -LogFile $LogFile -Level INFO -Message "Starting service w32time"
Start-Service -Name w32time

Write-Host "Initiating of the w32time service"
Write-Log -LogFile $LogFile -Level INFO -Message "Initiating of the w32time service"
Start-Process -FilePath "$Env:SystemRoot\system32\w32tm.exe" -ArgumentList "/config /update"
Start-Process -FilePath "$Env:SystemRoot\system32\w32tm.exe" -ArgumentList "/resync /rediscover"
Start-Process -FilePath "$Env:SystemRoot\system32\w32tm.exe" -ArgumentList "/query /peers"
Start-Process -FilePath "$Env:SystemRoot\system32\w32tm.exe" -ArgumentList "/query /status"
############################
# end section
############################

Write-Log -LogFile $LogFile -Level INFO -Message "##################################"
Write-Log -LogFile $LogFile -Level INFO -Message "### Script execution completed ###"
Write-Log -LogFile $LogFile -Level INFO -Message "##################################"

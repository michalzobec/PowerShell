#Requires -RunAsAdministrator
#Requires -Version 5
Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Get Application Users
    Lists users currently running a specified application.

.DESCRIPTION
    Get Application Users
    version 25.08.11.1
    Lists users currently running a specified application.
    The script searches for running processes by the specified application name 
    and displays which users are currently using the application.
    Useful to identify usage of Power BI Desktop, Excel, Word, etc.
    Requires running PowerShell with administrative privileges.

    (c) 2024-2025 Michal Zobec, ZOBEC Consulting. All Rights Reserved.  
    web: www.michalzobec.cz, mail: michal@zobec.net  
    GitHub repository http://zob.ec/getsystemreport
    License: [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/)

.PARAMETER AppName
    The process name of the application (without .exe), for example:
    - "PBIDesktop"
    - "excel"
    - "winword"

.EXAMPLE
    .\Get-AppUsers.ps1 -AppName "PBIDesktop"

    Displays the users currently running Power BI Desktop.

    #>

param (
    [Parameter(Mandatory = $true)]
    [string]$AppName
)

try {
    $procs = Get-Process -Name $AppName -IncludeUserName -ErrorAction SilentlyContinue |
    Select-Object `
    @{n = 'User'; e = { $_.UserName } },
    @{n = 'ProcessName'; e = { $_.ProcessName } },
    @{n = 'PID'; e = { $_.Id } },
    @{n = 'SessionId'; e = { $_.SessionId } },
    @{n = 'StartTime'; e = { $_.StartTime } }

    if (-not $procs) {
        Write-Host "The application '$AppName' is not currently running for any user."
    }
    else {
        Write-Host "Application '$AppName' is currently running for the following users:`n"
        $procs | Sort-Object User, StartTime | Format-Table -AutoSize

        "`nDistinct accounts:" | Write-Host
        $procs | Select-Object -ExpandProperty User -Unique | Sort-Object | ForEach-Object { $_ }
    }
}
catch {
    Write-Error "An error occurred: $_"
}

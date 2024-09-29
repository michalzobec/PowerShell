#Requires -RunAsAdministrator
#Requires -Version 2

<#
.SYNOPSIS
    Set Date and Time (Commandline Tool)
    (c) 2021-2024 ZOBEC Consulting, Michal Zobec. All Rights Reserved.
    Licensed under Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

.DESCRIPTION
    For single run get real date and time from internet service and configure date and time in running system.
    Can run on older systems like Microsoft Windows Server 2008, with PowerShell version 2.

.OUTPUTS
    Log file & text output.

.EXAMPLE
    C:\> Set-DateAndTime.ps1

.NOTES
    Twitter: @michalzobec
    Blog   : http://www.michalzobec.cz

.LINK
    http://www.michalzobec.cz

.LINK
    http://www.zobecconsulting.cz

.LINK
About this script on my Blog in Czech
http://zob.ec/

.LINK
Documentation (ReadMe)
https://github.com/michalzobec/

.LINK
Release Notes (ChangeLog)
https://github.com/michalzobec/

#>

# cls
# Enable TLS 1.2 for communication (if needed)
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Create an instance of WebClient
$webClient = New-Object System.Net.WebClient

# Download content from the API
$timeInfo = $webClient.DownloadString("http://worldtimeapi.org/api/timezone/Europe/Prague")

# Display the API response
Write-Host "API response: $timeInfo"

# Extract the date and time from the JSON response using a regular expression
$time = $timeInfo | Select-String -Pattern '"datetime":"([^"]+)"' | ForEach-Object {
    $_.Matches[0].Groups[1].Value
}

# Convert the extracted time to a format acceptable by Set-Date
$timeFormatted = Get-Date $time

Write-Host "Formatted time: $timeFormatted"

# Set the system date and time
Set-Date -Date $timeFormatted

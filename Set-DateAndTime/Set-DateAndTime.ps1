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

# Get the current script directory and timestamp for the log file
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $scriptDirectory "Set-DateAndTime-log-$timestamp.txt"

# Function to log messages to both console and log file
function Log-Message {
    param(
        [string]$message
    )
    Write-Host $message
    Add-Content -Path $logFile -Value "$message"
}

# Log the start of the script
Log-Message "Starting time update script at $(Get-Date)"

# Enable TLS 1.2 for communication (if needed)
# Log-Message "Enabling TLS 1.2 for communication"
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Function to check internet connectivity by pinging Google DNS (compatible with PowerShell 2.0)
function Test-InternetConnection {
    try {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $pingReply = $ping.Send("8.8.8.8")
        if ($pingReply.Status -eq "Success") {
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}

# Check if the system has an internet connection
if (-Not (Test-InternetConnection)) {
    Log-Message "No internet connection. Exiting script at $(Get-Date)"
    exit
}
Log-Message "Internet connection verified at $(Get-Date)"

# Create an instance of WebClient
$webClient = New-Object System.Net.WebClient
Log-Message "WebClient instance created."

try {
    # Download content from the API
    Log-Message "Attempting to download time data from API..."
    $timeInfo = $webClient.DownloadString("http://worldtimeapi.org/api/timezone/Europe/Prague")
    
    # Log the raw API response
    Log-Message "API response received: $timeInfo"

    # Extract the date and time from the JSON response using a regular expression
    Log-Message "Extracting datetime from API response..."
    $time = $timeInfo | Select-String -Pattern '"datetime":"([^"]+)"' | ForEach-Object {
        $_.Matches[0].Groups[1].Value
    }

    if ($time) {
        Log-Message "Datetime extracted from API response: $time"
    } else {
        Log-Message "Failed to extract datetime from API response."
        exit
    }

    # Convert the extracted time to a format acceptable by Set-Date
    Log-Message "Converting extracted datetime to system format..."
    $timeFormatted = Get-Date $time
    Log-Message "Formatted time for system: $timeFormatted"

    # Set the system date and time
    Log-Message "Setting system date and time..."
    Set-Date -Date $timeFormatted
    Log-Message "System time updated successfully at $(Get-Date)"

} catch {
    Log-Message "An error occurred: $_ at $(Get-Date)"
}

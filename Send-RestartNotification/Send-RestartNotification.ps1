<#
.SYNOPSIS
Send Restart Notification
Get information about last restart and send by email.

.DESCRIPTION
Send Restart Notification
version 24.10.25.014059
(c) 2019-2024 Michal Zobec, ZOBEC Consulting. All Rights Reserved.
web: www.michalzobec.cz, mail: michal@zobec.cz
License: Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) https://creativecommons.org/licenses/by-sa/4.0/

Documentation is in file readme.md.
Release notes is in file changelog.md.

.OUTPUTS
Log file in text format.

.EXAMPLE
C:\> Send-RestartNotification.ps1

.LINK
http://www.michalzobec.cz/

#>


# Define the log directory and ensure it exists
$logDir = Join-Path -Path (Get-Location) -ChildPath "logs"
if (-not (Test-Path -Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

# Specify log file location with the new format
$logFile = Join-Path -Path $logDir -ChildPath "Device-Was-Restarted-log-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

# Function to log output to both console and file
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    
    # Write to console
    Write-Host $logMessage

    # Write to log file
    Add-Content -Path $logFile -Value $logMessage
}

# Log start of script
Write-Log "Starting the restart notification script."

# Specify SMTP server and email addresses
$smtpServer = "zobec-cz.mail.protection.outlook.com"
$from = "michal@zobec.cz"
$to = "michal@zobec.cz"
$subject = "Server Restart Notification"

try {
    # Try to get the last restart event from the Event Log (event ID 1074 indicates a system restart)
    $eventLog = Get-WinEvent -LogName System -FilterXPath "*[System/EventID=1074]" -MaxEvents 1
    if ($eventLog) {
        # Extract details about the restart
        $restartTime = $eventLog.TimeCreated
        $eventMessage = $eventLog.Properties[2].Value
        $comment = $eventLog.Properties[5].Value
        $initiatingUser = $eventLog.Properties[6].Value

        # Use a placeholder if no comment is provided
        if (-not $comment) {
            $comment = "(no comment provided)"
        }

        Write-Log "Restart detected at $restartTime initiated by $initiatingUser."

    } else {
        # Default values if no event is found
        $restartTime = "(no restart event found)"
        $eventMessage = "(no event message)"
        $comment = "(no comment)"
        $initiatingUser = "(unknown)"

        Write-Log "No restart event found in the system logs."
    }

    # Format the email body in HTML
    $htmlBody = @"
<html>
<body>
    <h2>Server Restart Notification</h2>
    <p><strong>Time of Restart:</strong> $restartTime</p>
    <p><strong>Reason for Restart:</strong> $eventMessage</p>
    <p><strong>Comment:</strong> $comment</p>
    <p><strong>User who initiated the restart:</strong> $initiatingUser</p>
</body>
</html>
"@

    # Set the parameters for sending the email
    $emailParams = @{
        SmtpServer = $smtpServer
        From       = $from
        To         = $to
        Subject    = $subject
        Body       = $htmlBody
        BodyAsHtml = $true
    }

    # Send the email
    Send-MailMessage @emailParams
    Write-Log "Email sent successfully with restart details."

} catch {
    # Handle any errors that occur during script execution
    Write-Log "An error occurred: $_"
    Write-Log "Stack trace: $($_.Exception.StackTrace)"
}

Write-Log "Script execution finished."

#Requires -Version 2

# Get the current script directory and timestamp for the log file
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $scriptDirectory "Create-Job-log-$timestamp.txt"
$taskName = "Set-DateAndTimeOnStartup"
$scriptPath = Join-Path $scriptDirectory "Set-DateAndTime.ps1"  # Hlavní skript bude ve stejném adresáři

# Function to log messages to both console and log file
function Log-Message {
    param(
        [string]$message
    )
    Write-Host $message
    Add-Content -Path $logFile -Value "$message"
}

# Log the start of the script
Log-Message "Starting create-job script at $(Get-Date)"
Log-Message "Task name: $taskName"
Log-Message "Script path: $scriptPath"

# Check if the script exists
if (-Not (Test-Path -Path $scriptPath)) {
    Log-Message "Script file not found at $scriptPath. Exiting script."
    exit
}

# Create the task using schtasks command
try {
    # Properly escape the path and PowerShell command for schtasks
    $taskCmd = "`"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`" -File `"$scriptPath`""

    # Construct the schtasks command
    $action = @(
        "/create",
        "/tn", "`"$taskName`"",
        "/tr", "`"$taskCmd`"",
        "/sc", "onstart",
        "/f"
    )

    # Convert array to a single string for logging purposes
    $actionString = $action -join " "
    Log-Message "Creating task with the following command: $actionString"

    # Execute the schtasks command using Start-Process
    Start-Process schtasks -ArgumentList $action -NoNewWindow -Wait

    # Check if the task was created successfully
    if ($LASTEXITCODE -eq 0) {
        Log-Message "Task Scheduler job '$taskName' created successfully."
    } else {
        Log-Message "Failed to create Task Scheduler job. Exiting with error code $LASTEXITCODE."
        exit
    }

} catch {
    Log-Message "An error occurred: $_"
    exit
}

# Confirm task creation in Task Scheduler
try {
    $taskQuery = "schtasks /query /tn `"$taskName`""
    Log-Message "Verifying task creation with the following command: $taskQuery"
    
    # Execute the query command
    $taskResult = Invoke-Expression $taskQuery

    # Log the result of the query
    if ($taskResult) {
        Log-Message "Task verified successfully in Task Scheduler."
    } else {
        Log-Message "Task verification failed. Task may not exist."
    }

} catch {
    Log-Message "An error occurred during task verification: $_"
    exit
}

Log-Message "Create-job script completed at $(Get-Date)"

#Requires -RunAsAdministrator
#Requires -Version 5
Set-StrictMode -Version 5

<#
.SYNOPSIS
    ZOBEC Consulting
    Create New Users from List
    (c) 2020 ZOBEC Consulting, Michal Zobec. All Rights Reserved.

.DESCRIPTION
    Automation script, creating local accounts from CSV list.

.OUTPUTS
    Log file, created local accounts.

.EXAMPLE
    C:\> Create-NewUsersFromList.ps1

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

#-------------------------------------------------------------------------


#region variables
# special variables
$ScriptName = "Create New Users from List"
$ScriptVersion = "20.04.20.144059"
$ScriptShortVersion = "20.04.0"
$ScriptVersionStatus = "DEV WIP"
$dirScriptDirRoot = (Split-Path $myinvocation.MyCommand.Path)
$PasswordLength = 12
#regionend

#region function write-log
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

$LogDate = Get-Date -Format "yyyyMMdd.HHmm"
$LogFile = $dirScriptDirRoot + "\Create-NewUsersFromList-$LogDate.txt"
#regionend

#region header
Write-Host " "
Write-Host " "
Write-Host "ZOBEC Consulting"
Write-Host "$ScriptName"
Write-Host "Version $ScriptShortVersion $ScriptVersionStatus ($ScriptVersion)"
Write-Host "Copyright (c) 2020 ZOBEC Consulting, Michal Zobec. All Rights Reserved."
Write-Host "Licensed under Creative Commons Attribution-ShareAlike 4.0 International"
Write-Host " "
Write-Host "Script was started."
Write-Log -LogFile $LogFile -Message "ZOBEC Consulting" -Level INFO
Write-Log -LogFile $LogFile -Message "$ScriptName" -Level INFO
Write-Log -LogFile $LogFile -Message "Version $ScriptShortVersion $ScriptVersionStatus ($ScriptVersion)" -Level INFO
Write-Log -LogFile $LogFile -Message "Copyright (c) 2020 ZOBEC Consulting, Michal Zobec. All Rights Reserved." -Level INFO
Write-Log -LogFile $LogFile -Message "Licensed under Creative Commons Attribution-ShareAlike 4.0 International" -Level INFO
Write-Log -LogFile $LogFile -Message "Script was started." -Level INFO
#regionend

$InputFileName = $dirScriptDirRoot + "\UsersList.csv"
if (!(Test-Path $InputFileName)) {
    Write-Warning "The input file name you specified can't be found."
    Write-Log -LogFile $LogFile -Message "ZOBEC Consulting" -Level INFO
    exit
}
$GeneratedUsersList = $dirScriptDirRoot + "\GeneratedUsersList.csv"


#Enter a path to your import CSV file
$UsersList = Import-Csv "$InputFileName"
# Password length and character set to use for random password generation
$ascii = $NULL; For ($a = 33; $a -le 126; $a++) { $ascii += , [char][byte]$a }

Function Get-TempPassword() {

    Param(
        [int]$length = $PasswordLength,
        [string[]]$sourcedata
    )

    For ($loop = 1; $loop -le $length; $loop++) {
        $TempPassword += ($sourcedata | Get-Random)
    }
    return $TempPassword
}

foreach ($User in $UsersList) {

    $UserID = $User.UserID
    $FirstName = $User.Firstname
    $LastName = $User.Lastname
    $Description = $User.Description
    $IsAdmin = $User.IsAdmin
    $IsRemoteUser = $User.IsRemoteUser

    # split variables
    $FullName = "$LastName $FirstName"

    #Check if the user account already exists in AD
    # If (Get-LocalUser -F { Name -eq $UserID } -ErrorAction Continue) {
    #     #If user does exist, output a warning message
    #     Write-Warning "A user account $UserID has already exist in this system."
    #     Write-Log -LogFile $LogFile -Message "A user account $UserID has already exist in this system." -Level ERROR
    #     exit
    # }
    # Else {
    #     #If a user does not exist then create a new user account

    Write-Log -LogFile $LogFile -Message "Generating new password" -Level DEBUG
    $GetRandomPassword = Get-TempPassword -length $PasswordLength -sourcedata $ascii
    Write-Log -LogFile $LogFile -Message "New password '$GetRandomPassword' was generated" -Level DEBUG

    # converting to secure string
    Write-Log -LogFile $LogFile -Message "converting password to secure string" -Level DEBUG
    $NewPassword = ConvertTo-SecureString -String $GetRandomPassword -AsPlainText -Force
    Write-Log -LogFile $LogFile -Message "password was converted to secure string" -Level DEBUG

    # creating new account
    Write-Log -LogFile $LogFile -Message "Creating new account." -Level DEBUG
    Try {
        New-LocalUser -Name "$UserID" -FullName "$FullName" -Description "$Description" -Password $NewPassword -ErrorAction Stop
        Write-Log -LogFile $LogFile -Message "New-LocalUser Name '$UserID', FullName '$FullName', Description '$Description', Password '$NewPassword'" -Level DEBUG
    }
    Catch {
        Write-Log -LogFile $LogFile -Message "Creating of new account was failed." -Level DEBUG
        Write-Warning -Message "Creating of new account was failed."
        Write-Warning $_.Exception.Message
        Write-Log -LogFile $LogFile -Message "Error: '$_.Exception.Message'" -Level ERROR
        exit
    }

    # assigning Users group
    Try {
        Add-LocalGroupMember -Group "Users" -Member "$UserID" -ErrorAction Stop
        Write-Log -LogFile $LogFile -Message "Add-LocalGroupMember Group 'Users', Member '$UserID'" -Level DEBUG
    }
    Catch {
        Write-Warning $_.Exception.Message
        Write-Log -LogFile $LogFile -Message "Error: '$_.Exception.Message'" -Level ERROR
        exit
    }


    #region assigning Administrators group
    If ($IsAdmin -like $True) {
        Write-Log -LogFile $LogFile -Message "IsAdmin: True" -Level DEBUG
        try {
            Add-LocalGroupMember -Group "Administrators" -Member "$UserID" -ErrorAction Stop
            Write-Log -LogFile $LogFile -Message "Add-LocalGroupMember Group 'Administrators', Member '$UserID'" -Level DEBUG
        }
        catch {
            Write-Warning $_.Exception.Message
            Write-Log -LogFile $LogFile -Message "Error: '$_.Exception.Message'" -Level ERROR
            exit
        }
    }
    Else {
        Write-Log -LogFile $LogFile -Message "IsAdmin: False" -Level DEBUG
    }
    #regionend


    #region assigning Remote Desktop Users group
    If ($IsRemoteUser -like $True) {
        Write-Log -LogFile $LogFile -Message "IsRemoteUser: True" -Level DEBUG
        # assigning Remote Desktop Users group
        try {
            Add-LocalGroupMember -Group "Remote Desktop Users" -Member "$UserID" -ErrorAction Stop
            Write-Log -LogFile $LogFile -Message "Add-LocalGroupMember Group 'Remote Desktop Users', Member '$UserID'" -Level DEBUG
        }
        catch {
            Write-Warning $_.Exception.Message
            Write-Log -LogFile $LogFile -Message "Error: '$_.Exception.Message'" -Level ERROR
            exit
        }
    }
    Else {
        Write-Log -LogFile $LogFile -Message "IsRemoteUser: False" -Level DEBUG
    }
    #regionend

    # final message 
    Write-Log -LogFile $LogFile -Message "Created user account $UserID, with password '$GetRandomPassword'." -Level DEBUG
    # final message to special file
    Add-Content "$GeneratedUsersList" -Value "User: $UserID; Password: '$GetRandomPassword'`n"
    # }
}



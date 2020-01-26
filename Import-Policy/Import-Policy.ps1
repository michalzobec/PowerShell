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
$LogFile = $ScriptDir + "\Import-Policy-log-$LogDate.txt"
#endregion

#region work variables
$LgpoToolFile = "$ScriptDir\Tools\lgpo.exe"
#endregion

Write-Log -LogFile $LogFile -Level INFO -Message "##################################"
Write-Log -LogFile $LogFile -Level INFO -Message "### Script was started         ###"
Write-Log -LogFile $LogFile -Level INFO -Message "##################################"

############################
# section windows services
############################

#region custom variables
$TargetProductManufacturer = "Adobe"
$TargetProductName = "Reader"
$TargetProductPolicyRev = "20.01.19"
$PolicyType = "InternalComputer" # InternalComputer/InternalUser/InternalAudit/InternalSecurity/Native
#endregion

#region definition of type policy file structure
$PolicyRootDir = "$ScriptDir\Policy\$TargetProductManufacturer-$TargetProductName-Policy-$TargetProductPolicyRev"
# InternalComputer
$InternalComputerPolicyFilePath = "$PolicyRootDir\Computer\registry.pol"
# InternalUser
$InternalUserPolicyFilePath = "$PolicyRootDir\User\registry.pol"
# InternalAudit
$InternalAuditPolicyFilePath = "$PolicyRootDir\Audit\audit.csv"
# InternalSecurity
$InternalSecurityPolicyFilePath = "$PolicyRootDir\Security\GptTmpl.inf"
#endregion

# Check the LGPO tool exists
Write-Log -LogFile $LogFile -Level INFO -Message "Check if the LGPO tool exists ..."
if (!(Test-Path -Path $LgpoToolFile)) {
    Write-Log -LogFile $LogFile -Level INFO -Message "LGPO tool not exists ..."
    throw "$LgpoToolFile is not valid. Please provide a valid path to the LGPO tool."
}
Else {
    Write-Log -LogFile $LogFile -Level INFO -Message "LGPO tool exist ..."
}
#endregion

#region Check if the Policy file exists
Write-Log -LogFile $LogFile -Level INFO -Message "PolicyType: $PolicyType"

switch ($PolicyType) {
    "InternalComputer" {
        $PolicyFilePath = "$InternalComputerPolicyFilePath"
        $LgpoSwitch = "/m"
    }
    "InternalUser" {
        $PolicyFilePath = "$InternalUserPolicyFilePath"
        $LgpoSwitch = "/u"
    }
    "InternalAudit" {
        $PolicyFilePath = "$InternalAuditPolicyFilePath"
        $LgpoSwitch = "/ac"
    }
    "InternalSecurity" {
        $PolicyFilePath = "$InternalSecurityPolicyFilePath"
        $LgpoSwitch = "/s"
    }
}
Write-Log -LogFile $LogFile -Level DEBUG -Message "PolicyFilePath: $PolicyFilePath"
Write-Log -LogFile $LogFile -Level DEBUG -Message "LgpoSwitch: $LgpoSwitch"
#endregion

#region Check if the Policy file exists
Write-Log -LogFile $LogFile -Level INFO -Message "Check the PolicyFilePath file exists ..."
if (!(Test-Path -Path "$PolicyFilePath")) {
    Write-Log -LogFile $LogFile -Level INFO -Message "File PolicyFilePath not exists ..."
    throw "PolicyFilePath is not valid. Please provide a valid path to the PolicyFilePath file."
}
Else {
    Write-Log -LogFile $LogFile -Level INFO -Message "File PolicyFilePath exists ..."
}
#endregion

#region Importing Product Policy
Write-Log -LogFile $LogFile -Level INFO -Message "Importing Policy ($PolicyType) ..."
Write-Log -LogFile $LogFile -Level DEBUG -Message "Command line parameters: `"$LgpoSwitch $PolicyFilePath`""
Start-Process -FilePath "$LgpoToolFile" -ArgumentList "$LgpoSwitch $PolicyFilePath" -NoNewWindow
if($?) {
    Write-Log -LogFile $LogFile -Level DEBUG -Message "LGPO return value: True"
}

if (!$?) {
    Write-Log -LogFile $LogFile -Level DEBUG -Message "LGPO return value: False"
}
#endregion

# #region Verify imported Product Policy
# $RegistryPath = "HKLM\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown\cSharePoint"
# $RegistryName = "bDisableSharePointFeatures"
# $RegistryValue = "bDisableSharePointFeatures"
# Write-Log -LogFile $LogFile -Level INFO -Message "Verify imported Product Policy"
# Write-Log -LogFile $LogFile -Level DEBUG -Message "Registry path: `"$RegistryPath`""
# Write-Log -LogFile $LogFile -Level DEBUG -Message "Registry value: `"$RegistryName`""
# Write-Log -LogFile $LogFile -Level DEBUG -Message "Registry value: `"$RegistryValue`""
# #endregion


############################
# end section
############################

Write-Log -LogFile $LogFile -Level INFO -Message "##################################"
Write-Log -LogFile $LogFile -Level INFO -Message "### Script execution completed ###"
Write-Log -LogFile $LogFile -Level INFO -Message "##################################"

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
$LogFile = $ScriptDir + "\Clean-Policy-log-$LogDate.txt"
#endregion

Write-Log -LogFile $LogFile -Level INFO -Message "##################################"
Write-Log -LogFile $LogFile -Level INFO -Message "### Script was started         ###"
Write-Log -LogFile $LogFile -Level INFO -Message "##################################"

############################
# section windows services
############################

#region Removing Group Policy local cache
Write-Log -LogFile $LogFile -Level INFO -Message "Removing Group Policy local cache ..."
Write-Log -LogFile $LogFile -Level INFO -Message "Removing directory $env:windir\Sys­tem32\GroupPo­licy\ ..."
Remove-Item "$env:windir\Sys­tem32\GroupPo­licy\" -Force -Recurse -ErrorAction SilentlyContinue
Write-Log -LogFile $LogFile -Level INFO -Message "Removing directory $env:windir\Sys­tem32\GroupPo­licyUsers\ ..."
Remove-Item "$env:windir\Sys­tem32\GroupPo­licyUsers\" -Force -Recurse -ErrorAction SilentlyContinue
#endregion

#region Updating policy
Write-Log -LogFile $LogFile -Level INFO -Message "Updating policy ..."
Start-Process -FilePath "$env:windir\Sys­tem32\gpupdate.exe" -ArgumentList "/force" -NoNewWindow
if($?) {
    Write-Log -LogFile $LogFile -Level DEBUG -Message "gpupdate.exe return value: True"
}
if (!$?) {
    Write-Log -LogFile $LogFile -Level DEBUG -Message "gpupdate.exe return value: False"
}
#endregion

############################
# end section
############################

Write-Log -LogFile $LogFile -Level INFO -Message "##################################"
Write-Log -LogFile $LogFile -Level INFO -Message "### Script execution completed ###"
Write-Log -LogFile $LogFile -Level INFO -Message "##################################"

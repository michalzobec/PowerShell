#Requires -RunAsAdministrator
#Requires -Version 7
Set-StrictMode -Version 7

<#
.SYNOPSIS
    ZOBEC Consulting
    Remove Accounts
    (c) 2020 ZOBEC Consulting, Michal Zobec. All Rights Reserved.

.DESCRIPTION
    Automation script, creating local accounts from CSV list.

.OUTPUTS
    Log file, created local accounts.

.EXAMPLE
    C:\> Remove-Accounts.ps1

.NOTES
    Twitter: @michalzobec
    Blog   : http://www.michalzobec.cz

.LINK
    http://www.michalzobec.cz

#>

#-------------------------------------------------------------------------

Write-Host "Removing account 'A1234'"
Remove-LocalUser "A1234" -ErrorAction Continue

Write-Host "Removing account 'B2345'"
Remove-LocalUser "B2345" -ErrorAction Continue

Write-Host "Removing account 'C3456'"
Remove-LocalUser "C3456" -ErrorAction Continue

Write-Host "Removing account 'D4567'"
Remove-LocalUser "D4567" -ErrorAction Continue

Write-Host "Removing account 'E5678'"
Remove-LocalUser "E5678" -ErrorAction Continue

Write-Host "Removing account 'F6789'"
Remove-LocalUser "F6789" -ErrorAction Continue

Write-Host "Removing account 'G7890'"
Remove-LocalUser "G7890" -ErrorAction Continue

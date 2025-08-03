<#
.SYNOPSIS
Get User Profile Disks Free Space
Version 25.08.03.1
Get free space for current user profile using User Profile Disks (UPD) on Windows Server with Remote Desktop Services.
Script supports run locally.

.DESCRIPTION
Get User Profile Disks Free Space
Copyright (c) 2025 Michal Zobec, ZOBEC Consulting. All Rights Reserved.
web: www.michalzobec.cz, mail: michal@zobec.cz
License: Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0) https://creativecommons.org/licenses/by-sa/4.0/

Documentation is in file ReadMe.md.

.OUTPUTS
After run get free space in user profile disk (UPD) to console output.

.EXAMPLE
C:\> Get-UserProfileDisksFreeSpace.ps1

.LINK
http://www.michalzobec.cz/
#>

# Load the required C# type for calling Windows API GetDiskFreeSpaceEx
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class DiskSpaceInfo
{
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern bool GetDiskFreeSpaceEx(
        string lpDirectoryName,
        out ulong lpFreeBytesAvailable,
        out ulong lpTotalNumberOfBytes,
        out ulong lpTotalNumberOfFreeBytes);
}
"@

# Path to check - e.g., a mounted VHD user profile
$path = "$env:USERPROFILE"

# Output variables
[System.UInt64]$free = 0
[System.UInt64]$total = 0
[System.UInt64]$totalFree = 0

# Call the API
$result = [DiskSpaceInfo]::GetDiskFreeSpaceEx($path, [ref]$free, [ref]$total, [ref]$totalFree)

if ($result) {
    $freeGB = [math]::Round($free / 1GB, 2)
    $totalGB = [math]::Round($total / 1GB, 2)
    Write-Output "Free space: $freeGB GB out of $totalGB GB at path: $path"
} else {
    Write-Warning "GetDiskFreeSpaceEx call failed for path: $path"
}

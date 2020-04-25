
<#

.SYNOPSIS
Create Windows service.

.DESCRIPTION
Create Windows service.

.PARAMETER
Script does not support input parameters. Configuration is possible via variables in this script. For more information see to Variables section.

.OUTPUTS
Output forwarded to file create-windowsservice.log.

.EXAMPLE
C:\> create-windowsservice.cmd

.LINK
http://www.michalzobec.cz/

.NOTES
Create Windows Service (TEMPLATE)
version 17.04.16.1
Create Windows Service (command line tool).
(c) 2015-2017 Michal Zobec, ZOBEC Consulting. All Rights Reserved.
web: www.michalzobec.cz

*Variables*
ServiceName. System name of Windows service (without spaces in name).
ServiceDisplayName. Name of Windows service presented in list of Windows services.
ServiceDescription. Service description.
ServicePathName. Full file path to executable file.
ServiceDependency. Dependency on another Windows services.
#>


## promenne - zacatek
$ServiceName          ='ZobecExampleService'
$ServiceDisplayName   ='ZOBEC Consulting Example Service'
$ServiceDescription   ='Example service.'
$ServicePathName      ='C:\Program Files\ZOBEC Consulting\Example Service\ExampleService.exe'
$ServiceDependency    ='MSSQLSERVER'
## promenne - konec

if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)
{
    write-host "Sluzba $ServiceName jiz existuje"
    exit
}

new-service -name $ServiceName -displayName $ServiceDisplayName -description $ServiceDescription -DependsOn $ServiceDependency -binaryPathName $ServicePathName
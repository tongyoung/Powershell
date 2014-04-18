<#
.SYNOPSIS
    This script creates a logfile with some  information
	everytime a user logs on to the computer
.EXAMPLE
    Advanced-Event-3.ps1 
#>

$logname = "logonstatus.txt"
$logdir = "c:\logonlog\"
$fulllogname = "$logdir$logname"

#Put WMI classes into variables so we can get data we need later
$ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
$OperatingSystem = Get-WmiObject -Class Win32_OperatingSystem
$MappedLogicalDisk = Get-WmiObject -Class Win32_MappedLogicalDisk 

# Grab data and assign labels for use in custom object later
$LogData = @{
	LastReboot = $OperatingSystem.ConvertToDateTime($OperatingSystem.LastBootUpTime)
	ComputerName = "{0}.{1}" -f $ComputerSystem.Name, $ComputerSystem.Domain
	Username = $ComputerSystem.UserName
	OperatingSystemVersion = $OperatingSystem.Version
	CurrentLog = Get-Date
	OperatingSystemServicePack = $OperatingSystem.ServicePackMajorVersion
	DefaultPrinter = (Get-WmiObject win32_printer -filter "Default='True'").Name
	Drive = Get-WmiObject Win32_MappedLogicalDisk | Select @{Name="Drive Letter";Expression={$_.DeviceID}}, `
		@{Name="Resource Path";Expression={$_.ProviderName}}
	TypeOfBoot = $ComputerSystem.BootupState
	}

# Checking for directory and file
if (!(Test-Path -Path $logdir)) {New-Item -Path $logdir -Type Directory}
if (!(Test-Path -Path $fulllogname)) {New-Item -Path $fulllogname -Type File}

# Select order of data to match picture in task and output to file and append data
New-Object PSObject -Property $LogData | 
	Format-List LastReboot,ComputerName,Username,OperatingSystemVersion,CurrentLog,`
	OperatingSystemServicePack,DefaultPrinter,Drive,TypeofBoot | 
	Out-File -FilePath $fulllogname -Append
	

	



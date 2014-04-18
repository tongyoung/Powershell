<#
.SYNOPSIS
	This script makes a csv file of uptimes of servers
.EXAMPLE
    Advanced-Event-6.ps1 
.EXAMPLE
    Advanced-Event-6.ps1 -Computername TEST01,TEST02
.DESCRIPTION
	Advanced-Event-6.ps1
.PARAMETER COMPUTERNAME
	A string value
#>
Param([String[]]$Computername = $env:COMPUTERNAME)

# Define output object
function New-Uptime {
    New-Object PSObject -Property @{
        Computername = ""
        Days = ""
		Hours = ""
		Minutes = ""
		Seconds = ""
		Date = ""
    }
}

# Construct filename that we will write to
$filename = (Get-Date -UFormat "%Y%m%d") + "_Uptime.csv"
$dir = "C:\2012sg"	
$FullFileName = "$dir\$filename"

# initialize our array
$Uptimes = @()

# If the csv exists already, we will read in the data into our array
if (Test-Path -Path $FullFileName) {
	$ImportedCSV = Import-Csv -Path $FullFileName
	$Uptimes += $ImportedCSV
	}

# set the report time to 8am as specified in task
$ReportTime = Get-Date -Hour 8 -Minute 0 -Second 0

# Go through each computername and calculate values
$Computername | Foreach {

	# Use win32_operatingsystem to figure out LastBootUpTime.  If this command does not
	# work then we'll just skip this computername
	if (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $_ -ErrorAction SilentlyContinue) {
		$OperatingSystem = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $_ 
	
		# Get last boot up time and convert to human readable date/time
		$LastBoot = $OperatingSystem.ConvertToDateTime($OperatingSystem.LastBootUpTime)
	
		# Subtract last boot up time from 8am to calculate uptime.
		# If the uptime is less than 0 (meaning computer was rebooted after 8am today)
		# then we will insert 0 values into days, hours, minutes, and seconds
		$Uptime = $ReportTime - $LastBoot
		$tempArray = New-Uptime
		$tempArray.Computername = $_
			
		if ($Uptime -gt 0) {
			$tempArray.Days = $Uptime.Days
			$tempArray.Hours = $Uptime.Hours
			$tempArray.Minutes = $Uptime.Minutes
			$tempArray.Seconds = $Uptime.Seconds
			$tempArray.Date = (Get-Date $LastBoot -UFormat "%m/%d/%Y")
			$Uptimes += $tempArray
			}
		else {
			$tempArray.Days = "0"
			$tempArray.Hours = "0"
			$tempArray.Minutes = "0"
			$tempArray.Seconds = "0"
			$tempArray.Date = (Get-Date $LastBoot -UFormat "%m/%d/%Y")
			$Uptimes += $tempArray
		}
	}
}

# File will always be overwritten with the Export-CSV command, which is why we imported
# the existing file at the beginning of the script since Export-CSV didn't have an -append option
# and ConvertTo-CSV created duplicate headers when appending to file
$Uptimes | Select-Object Computername, Days, Hours, Minutes, Seconds, Date  | 
	Export-Csv -Path $FullFileName -NoTypeInformation

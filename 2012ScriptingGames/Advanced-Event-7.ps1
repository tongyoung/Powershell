<#
.SYNOPSIS
	This script outputs to the screen the first event of each log that contains an entry sorted by date.
.DESCRIPTION
	Advanced-Event-7.ps1
#>

# Define output object to hold log information


function New-Log {
    New-Object PSObject -Property @{
		TimeCreated = ''
		Logname = ''
		ID = ''
		Message = ''
    }
}

# Initialize array
$Logs = @()

# Get all logs and filter for at least 1 event, then add it to our $logs array for processing later
Get-WinEvent -listlog * -Force | Where-Object {$_.RecordCount -gt 0} | 
	Foreach {
		$templog = Get-WinEvent -logname $_.logname -MaxEvents 1 
		$TempArray = New-Log
		$TempArray.TimeCreated = $templog.TimeCreated
		$TempArray.Logname = $templog.Logname
		$TempArray.ID = $templog.ID
		$TempArray.Message = $templog.Message
		$Logs += $TempArray
			}

# Sort object by TimeCreated in descending order.
$Logs | Sort-Object TimeCreated -Descending | Format-List TimeCreated, Logname, ID, Message 
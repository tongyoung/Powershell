<#
.SYNOPSIS
	This script counts all the error messages from each log
	file on a computer and counts them up and sorts
.EXAMPLE
    Advanced-Event-5.ps1 
.EXAMPLE
    Advanced-Event-5.ps1 -Computername TEST01,TEST02
.DESCRIPTION
	Count number of error messages in all event logs on a computer
.PARAMETER COMPUTERNAME
	A string value
#>

param([String[]]$Computername=$env:COMPUTERNAME)

# Get all log names.  Added the target computername into the write-host message so you can identify different
# computers from each other
Foreach ($Name in $Computername) {
	$logs = Get-EventLog -List -ComputerName $Name -ErrorAction SilentlyContinue
	ForEach ($log in $logs) {
		Write-Host Accessing $log.LogDisplayName log on $Name
		Try {
		Get-Eventlog -log $log.log -ComputerName $Name -EntryType Error -ErrorAction Stop | 
			Group-Object Source | Sort-Object Count -Descending | Format-Table -Property Count,Name -AutoSize
			}
	
		Catch {
		Write-Host "No Access"
		}
	}
}


	
<#
.SYNOPSIS
	Use the Win32_SystemEnclosure class to figure out if the computer is a desktop or laptop.
	Returns value of True if it is a desktop, and False if it is a laptop and writes a warning
	message if it can't figure it out. Script tested with non-admin account and worked fine so no
	check for administrator rights is needed
.EXAMPLE
    Beginner-Event-8.ps1 
.DESCRIPTION
	Values of note from ChassisTypes property which we will use in a switch statement
	3 Desktop
	4 Low Profile Desktop
	5 Pizza Box
	6 Mini Tower
	7 Tower
	8 Portable
	9 Laptop
	10 Notebook
	11 Hand Held
.LINK
	http://msdn.microsoft.com/en-us/library/windows/desktop/aa394474%28v=vs.85%29.aspx
#>

# Simple function to return True if ChassisTypes matches a number for a deskop (3-7) and 
# False if it returns a number for a laptop (8-11)

function Get-ChassisType ($Computername){
$ChassisType = (Get-WmiObject -Class Win32_SystemEnclosure -Computername $Computername).ChassisTypes
Switch ($ChassisType)
{
	{$_ -gt 2 -and $_ -lt 8} {$true}
	{$_ -gt 7 -and $_ -lt 12} {$false}
	}
}

Get-ChassisType -Computername $env:COMPUTERNAME
	


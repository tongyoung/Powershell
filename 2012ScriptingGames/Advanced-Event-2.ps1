
<#
.SYNOPSIS
    This script finds information about remote or local
	services and outputs it to a csv file which is opened
	by Excel
.EXAMPLE
    Advanced-Event-2.ps1 
.EXAMPLE
    Advanced-Event-2.ps1 -Computername TEST01 
.DESCRIPTION
	Find Information about Remote and Local Services
.PARAMETER COMPUTERNAME
	A string value
#>

param([string]$Computername)

# Check if Administrator rights are present
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
   {
      Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
      Break
    }


$csvfile = ".\myserviceStatus.csv"

$splattable = @{}
$splattable['Class'] = "Win32_service"

# Running on localhost, so need to add impersonation level
if ($computername -eq "") {
	$computername = Get-Content env:computername
	$splattable['Impersonation'] = "3"
}

# Computername was specified so we need to get credentials
else { $splattable['Computername'] = "$computername"
	$splattable['Credential'] = (Get-Credential)
}

Get-WmiObject @splattable | 
	Select-Object __SERVER, Name, StartMode, State, StartName | 
	Export-Csv -Path $csvfile -NoTypeInformation
	
Invoke-Item $csvfile
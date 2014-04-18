#NetEnabled
#
#    Data type: boolean
#    Access type: Read-only
#
#    Indicates whether the adapter is enabled or not. If True, the adapter is enabled. You can enable or disable the NIC by using the Enable and Disable methods.
# CHECK FOR ADMIN RIGHTS
# TODO: CHECK FOR VISTA OR HIGHER
# IF BOTH NICS DISABLED PROMPT TO ENABLE ONE
# IF BOTH NICS ENABLED PROMPT TO DISABLE ONE


$computername = $env:COMPUTERNAME

function IsLaptop ($Computername){
	$ChassisType = (Get-WmiObject -Class Win32_SystemEnclosure -Computername $Computername).ChassisTypes
	If ($ChassisType -gt 7 -and $ChassisType -lt 12) {$true}
	else {$false}
}

# Check if this computer is a laptop
If (IsLaptop $computername) {

	# Check if Vista or higher for OS
	if (((Get-WmiObject win32_operatingsystem).version -split "\.")[0] -ge 6) {
		# find the adapter you need with this class
		$ethernet = get-wmiobject -class win32_networkadapter -filter "Name like '%ethernet%'"
		$wireless = get-wmiobject -class win32_networkadapter -filter "Name like '%wireless%'"
	 
	 }
	else {
	 }
 
}

<#
	.SYNOPSIS
		This will just search for an wilcard name for a software and return if it is found with version and name.
		The examples here are just for splunk, but they can be used for anything.  Probably only works on Windows 2008 version
		and above.

	.PARAMETER  Name
		This will be the name of the software

	.PARAMETER Remove
		If you enable this switch it will try to uninstall the software

	.EXAMPLE
		PS C:\> Check-Software.ps1 -Name Splunk
		
		IdentifyingNumber : {814459fa-a522-4f0f-bcf1-a0d386a86703}
		Name              : Splunk
		Vendor            : Splunk, Inc.
		Version           : 107.2.31363
		Caption           : Splunk
	
	.NOTES
		tyoung
#>
	[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		$Name,
		# use 1 for true, and 0 for false
		[Parameter(Position=1)]
		$Remove
		)
	try {
		# Let's clear the errors so we don't pickup errors from before
		$Error.Clear()
		$Name = "*$name*"
		
		# We are just going to try to grab the object, or objects that match our wildcard name
		$software = Get-WmiObject win32_product -ea 0 | Where-Object {$_.name -like $name}
		$software
		"Remove variable: $($Remove)"
		# If the uninstall switch ie enabled, and if we find just once instance of software then let's uninstall it.  
		# Need to be careful with wildcard searches or we might end up uninstalling more software than we intended to
		if ($Remove) {
			
			if (($software | Measure-Object | select -ExpandProperty Count) -eq 1)
				{
				"Trying to uninstall $($software.name)"
				$software.uninstall()
				if ($?) {
					"$($software.name) uninstalled"
					}
				else {
					"Something went wrong uninstalling $($software.name), please check manually"
					}
				}
		}
		
		#If the software is not found let's write some output
		if (($software | Measure-Object | select -ExpandProperty Count) -eq 0) {
			"Software $name was not found to be installed"
			}
	
	}
	catch {
		"Something went wrong with WMI query"
	}
	


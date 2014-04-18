<#
.SYNOPSIS
	This script figures out the total size of files in folders
.EXAMPLE
    Advanced-Event-4.ps1 
Folder                                                            Size of Folder                                                  
------                                                            --------------                                                  
c:\data\2012                                                      18.64MB                                                         
C:\data\2012\HSG_2_13_12                                          30.29MB                                                         
C:\data\2012\HSG_2_20_12                                          26.06MB                                                         
C:\data\2012\HSG_2_27_12                                          23.45MB                                                         
C:\data\2012\HSG_2_6_12                                           24.82MB   
.EXAMPLE
    Advanced-Event-4.ps1 -Path "C:\Data\2012\HSG_2_13_12"
Folder                                                            Size of Folder                                                  
------                                                            --------------                                                  
C:\Data\2012\HSG_2_13_12                                          30.29MB                                                        
.DESCRIPTION
	Find Information about Remote and Local Services
.PARAMETER PATH
	Supply a path name that you want to search
	Default value is "C:\data\2012"
#>

param([string]$Path="c:\Data\2012")

function Get-FolderSize($path) {
  Get-ChildItem $path -Force | 
    Measure-Object -Property Length -Sum | 
    Select-Object -ExpandProperty Sum
}

function Round-Size ($size) {
	Switch ($size) {

		{$size -gt 1GB} { “$([math]::Round(($Size / 1GB),2))GB” ; Break }
		{$size -gt 1MB} { “$([math]::Round(($Size / 1MB),2))MB” ; Break }
		default { “$([math]::Round(($Size / 1KB),2))KB” }

	}	
}

# Define output object
function New-Project {
    New-Object PSObject -Property @{
        Folder = ''
        "Size of Folder" = ''
    }
}

# Test if parameter path exists

if (Test-Path $Path) {

	$FolderSizes = @()

	$Size = (Get-FolderSize $Path)
	$RoundedSize = Round-Size $Size

	$tempArray = New-Project
	$tempArray.Folder = $Path
	$tempArray."Size of Folder" = $RoundedSize
	$FolderSizes += $tempArray

	# Check if there are any additional folders below the Path specified, if so we will rerun
	# previous functions and add to array $FolderSizes

	If ((Get-ChildItem -Path $Path | Where-Object {$_.PSIsContainer}).count -gt 0) {
		$folders = Get-ChildItem -Path $Path -Recurse | Where-Object {$_.PSIsContainer} | 
			Select-Object FullName

		ForEach ($folder in $folders) {
			$size = (Get-FolderSize $folder.FullName)
			$RoundedSize = Switch ($size) {

				{$size -gt 1GB} { “$([math]::Round(($Size / 1GB),2))GB” ; Break }
				{$size -gt 1MB} { “$([math]::Round(($Size / 1MB),2))MB” ; Break }
				default { “$([math]::Round(($Size / 1KB),2))KB” }

			}	
		$tempArray2 = New-Project
		$tempArray2.Folder = $folder.FullName
		$tempArray2."Size of Folder" = $RoundedSize
		$FolderSizes += $tempArray2
		}
	}

	$FolderSizes | Sort-Object "Size of Folder" -Descending
}
Else { Write-output "$path is invalid, please try a different path" }

# full path of script $pscommandpath
# $psscriptroot root of script
#
# Just a simple install script to run the powershellv4 installer on multiple machines

$PowershellFolder = "UNC_OF_FOLDER_FOR_POWERSHELL"
$DotnetFolder = "UNC_OF_FOLDER_FOR_DOTNET_WHICH_IS_REQUIRED_FOR_POWERSHELLV4"

if ($PSVersionTable.Item("psversion").major -ne 4) {

	if ((Get-WmiObject win32_operatingsystem).version -match "6.2") {
		# This server matches windows 2012
		# Add .Net 4.5 and install powershellv4 for 2012
		$Net = "net-framework-45-features","net-framework-45-core"
		$features = @()
		"If .Net 4.5 is not installed we will add it in"
		$Net | foreach {
			if (!(get-windowsfeature $_).installed) { $features += $_ }
		}
		if ($features) {
			"Going to install some features of .Net that were not found: $features"
			add-windowsfeature $features
		}

		"Going to install powershell v4"
		cmd /c "C:\windows\system32\wusa.exe $PowershellFolder\windows2012.msu /quiet /forcerestart"
	}

	if ((Get-WmiObject win32_operatingsystem).version -match "6.1") {
		# This server match windows 2008
		# We need to install dotnet4.5 with an install file
		
		$net45match = "" 
		$net45match = (Get-WmiObject win32_product).Name -match "Framework 4.5"
		if (!$net45match) {
			# We need to install .Net 4.5, but we get an error from file shares, so we should try to copy it locally
			"We need to install .Net 4.5"
			$TempPath = "C:\temp"
			if (!(test-path $TempPath)) {New-Item -Path $TempPath -Type directory}
			Copy-Item -Path (get-childitem -Path $DotnetFolder -Filter "dotnetfx45*").fullname -Destination $TempPath -Force
			#& 'c:\temp\dotNetFx45_Full_setup.exe' /quiet /norestart
			start-process -Filepath "$temppath\dotnetfx45_full_setup.exe" -ArgumentList /quiet,/norestart -Wait
			do {start-sleep 5} while (Get-Process -ProcessName *dotnetfx45*)
			
		}

		"Going to install powershell v4"
		#cmd /c "C:\windows\system32\wusa.exe $PowershellFolder\windows2008.msu /quiet /forcerestart"
		$a = "wusa"
		$b = "$PowershellFolder\windows2008.msu"
		#Start-Process -FilePath "C:\windows\system32\wusa.exe" -ArgumentList "$PowershellFolder\windows2008.msu /quiet /forcerestart" -Wait
		& $a $b /quiet /forcerestart | Out-Null
		do {start-sleep 5} while (Get-Process -ProcessName wusa -ea 0)

	}

}

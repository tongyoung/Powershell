<#
.SYNOPSIS
	This script lists the name and process ID of each process
	running on my computer
.EXAMPLE
    .\Beginner-Event-3.ps1 -filename "Process1.txt" -filepath "c:\2012sg\Event3A\"

    Directory: C:\2012sg\Event3A


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---          4/4/2012   2:40 PM          0 Process1.txt

.EXAMPLE
    .\Beginner-Event-3.ps1 -filename "Process1.txt"

    Directory: C:\2012sg\event3


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---          4/4/2012   2:40 PM          0 Process1.txt 

.EXAMPLE
	.\Beginner-Event-3.ps1 -filepath "c:\2012sg\Event3A\"

    Directory: C:\2012sg\Event3A


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---          4/4/2012   2:41 PM          0 Process3.txt

.DESCRIPTION
	This script lists the name and process ID of each process
	running on my computer
.PARAMETER Filename
	This will be the name of the file that you want to output results to
.PARAMETER FilePath
	This will be the folder you want to output results to
#>

param([string]$filename = "Process3.txt" , [string]$filepath = "C:\2012sg\event3\")

[string]$fullfilename = "$filepath$filename"

if (!(Test-Path -Path $filepath)) {New-Item -ItemType Directory -Path $filepath}

if (Test-Path -path "$fullfilename") {
	Remove-Item -Path "$fullfilename"
	New-Item -ItemType File -Path "$fullfilename" 
	}
else {
	New-Item -ItemType File -Path "$fullfilename" 
	}
	
# File was showing up as wider than 80 characters, so I added the -Width argument to Out-File so
# it would fit properly on my screen

Get-Process | Select-Object Name, ID | Out-File -Append -FilePath $fullfilename -Width 80

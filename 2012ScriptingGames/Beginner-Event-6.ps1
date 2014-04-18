# get computername variable for localhost as specified in task
$Computername = $env:COMPUTERNAME

# Use win32_operatingsystem class as specified in task
$OperatingSystem = Get-WmiObject -Class Win32_OperatingSystem 

# Get last boot up time and convert to human readable date/time
$LastBoot = $OperatingSystem.ConvertToDateTime($OperatingSystem.LastBootUpTime)

# Get current time and subtract last boot up time to calculate uptime
$Uptime = (Get-Date) - $LastBoot

#Make output similar to picture for task
Write-Host The computer $Computername has been up for $Uptime.Days days $Uptime.Hours hours `
$Uptime.Minutes minutes and $Uptime.Seconds seconds as of $LastBoot
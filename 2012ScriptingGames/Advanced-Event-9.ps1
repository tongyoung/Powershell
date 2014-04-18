# All computers are Windows 7

[Int64]$memory = 0
$ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
$Processor = Get-WmiObject -Class Win32_Processor
$OperatingSystem = Get-WmiObject -Class Win32_OperatingSystem
$NetworkAdapters = Get-WmiObject -Class Win32_networkadapterconfiguration -filter "description like '%Gigabit%'"
$NicIndex = ($NetworkAdapters | Measure-Object -Property Index -Minimum).minimum

$PhysicalMemory = Get-WmiObject -Class Win32_PhysicalMemory
$PhysicalMemory | foreach { $memory += $_.capacity}


$Inventory = New-Object -TypeName PsObject -Property @{
	Computername = $ComputerSystem.Name
	Domain = $ComputerSystem.Domain
	Manufacturer = $ComputerSystem.Manufacturer
	Model = $ComputerSystem.Model
	NumberOfCPU = $ComputerSystem.NumberOfProcessors
	NumberOfCores = $Processor.NumberOfCores
	SpeedOfProcessor = $Processor.MaxClockSpeed
	ProcessorID = $Processor.ProcessorId
	OSVersion = $OperatingSystem.Version
	OSServicePack = $OperatingSystem.ServicePackMajorVersion
	MaxMemoryGB = $memory/1GB
}

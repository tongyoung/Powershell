Get-Counter -ListSet Processor | Select-Object -ExpandProperty Paths | Get-Counter -MaxSamples 3 -SampleInterval 5 | 
  Out-File -FilePath (Join-Path -Path ([Environment]::GetFolderPath("MyDocuments")) -ChildPath "$($env:COMPUTERNAME)_ProcessorCounters.txt") -Append

param([string]$Computername="$env:computername")

# Can pipe this to Out-File if necessary
Get-EventLog -Logname Application -ComputerName $Computername | Group-Object Source | 
	Select-Object Count,Name | Sort-Object Count -descending | Format-Table -autosize 
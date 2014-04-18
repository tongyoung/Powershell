# Task says to find any applications attempting to veto the shutdown
Get-EventLog -LogName Application -Source "Microsoft-Windows-Winsrv" -InstanceId 10001 -Message "*veto the shutdown*" | 
	Sort-Object TimeGenerated -Descending | select TimeGenerated, ReplacementStrings 
	
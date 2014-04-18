Get-WinEvent -Listlog * -Force | Where-Object {$_.RecordCount -gt 0 -and $_.IsEnabled} | 
	Sort-Object RecordCount -descending | Format-Table LogName, RecordCount -autosize 

# Comment from judge:
# missing -erroraction silentlycontinue parameter on get-winevent, errors will be written to host.
# other than that, excellent!
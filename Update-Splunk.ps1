# Heartbleed vulnerability in all my splunkforwarder installs.  Quick script to check for any active servers and run
# a different script to update splunkforwarder on them.  Using background jobs to speed up the process  -Scriptblock {}
# has been sanitized

$checkdate=(get-date).adddays(-30)
$cred = get-credential 

Get-ADComputer -Filter 'PasswordLastSet -gt $checkdate' -Properties PasswordLastSet -SearchBase "OU=Servers,DC=corp,DC=ingenio,DC=com" | 
    select DnsHostName  | 
       foreach {invoke-command -ComputerName $_.dnshostname -Credential $cred -Authentication credssp -scriptblock {if ('6.0.3.204106' -ne (Get-WmiObject win32_product | Where-Object {$_.name -match "forward"} |	
       	select -ExpandProperty version)) {Install-Splunk.ps1 -force}} -asjob}



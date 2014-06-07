<#
   .Synopsis
	This is the script that will install splunkforwarder service on clients
   .Example
    Install-Splunk.ps1
   .Example
    Install-Splunk.ps1 -Force  
   .Parameter Force
    Use this switch if you want to force a re-install or update versions
#>

Param(
[switch]$Force
)

$SplunkFolder = "UNC_OF_SPLUNK_FOLDER"
$SplunkVersion = "6.0.3-204106"
$SplunkFile = Get-ChildItem -Path $SplunkFolder -Filter "splunkforwarder-$SplunkVersion*"
$InputFile = "C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf"
$Domain = (Get-WmiObject win32_computersystem).domain
$OutputFileSource = "PATH_TO_OUTPUTS.CONF_FILE"
$OutputFile = "C:\Program Files\SplunkUniversalForwarder\etc\system\local\outputs.conf"
$InputFileSource = "PATH_TO_INPUTS.CONF_FILE"

if (get-service splunkforwarder -ea 0) {
    "Splunk forwarder already installed"
    if (!$force) {
        "-Force argument not used, exiting"
	   Start-Sleep 5
	   exit 1
        }
    }

""
"Going to install splunk forwarder"

Start-Sleep 1

if ((get-service splunkforwarder -ea 0).status -eq "Running") {
    Stop-Service Splunkforwarder -verbose -ea 0
    }

msiexec /i $SplunkFile.FullName /passive AGREETOLICENSE=YES RECEIVING_INDEXER="indexer_fqdn_here" LAUNCHSPLUNK=0 MONITOR_PATH="C:\log" WINEVENTLOG_APP_ENABLE=1 WINEVENTLOG_SEC_ENABLE=1 WINEVENTLOG_SYS_ENABLE=1 WINEVENTLOG_FWD_ENABLE=1 WINEVENTLOG_SET_ENABLE=1 | Out-Null
$SplunkCmd = gci -Path 'C:\Program Files' -Recurse -Filter splunk.exe
cd $SplunkCmd.directoryname
if (test-path c:\log) {.\splunk.exe add monitor c:\log -auth admin:changeme}
.\splunk.exe set servername "$env:computername.$domain" -auth admin:changeme
.\splunk.exe set default-hostname "$env:computername.$domain" -auth admin:changeme

#stop-service splunkforwarder -Verbose -ea 0

"Modifying inputs.conf"
Get-Content $InputFileSource | Out-File $InputFile -Append -Encoding ascii
Copy-Item $OutputFileSource $OutputFile -Force -Verbose
start-service splunkforwarder -Verbose
"Splunk forwarder installation done"




# This is just the framework for the final script
# Does not seem to work on domain controllers
# This is only needed on Windows2008, as Windows2012 has MSMQ cmdlets
# TODO
# context-based help
# parameters
# function for creationg of queue
# function for deletion of queues
# switch for different queue names depending on type
# permissions for queues

Param(
	$Computername,
	[switch]$Distributor,
	[switch]$SipReceiver,
	[switch]$MSMQReceiver
	)
	
function Redo-ReceiverQueues {Param (
	$Computername,
	$Queue,
	$msmq,
	$QueueACL = "",
	$Domain = (Get-WmiObject win32_computersystem).domain -replace "\..*"
	)
	$Computername = $Computername.substring(0,1).toupper()+$Computername.substring(1).tolower()
	$QueuePath = "$Computername\$Computername$Queue"
	"Checking for $QueuePath"
	if ($msmq::exists($QueuePath)) {
		"$QueuePath exists.  We are going to delete it"
		$msmq::delete($QueuePath)
		}
	"Creating $QueuePath"
	$Q = $msmq::Create($QueuePath)
	$Q.UseJournalQueue = $TRUE
	$Q.MaximumJournalSize = 51200
	$Q.Label = "$Computername$Queue"
	$q.SetPermissions("$Domain\svc_comservice", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Set)
	$q.SetPermissions($QueueACL, [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Set)
	$q.SetPermissions("Anonymous Logon", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Revoke)
	$q.SetPermissions("Everyone", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Revoke)

	}

function Redo-DistributorQueues {Param (
	$Computername,
	$Queue,
	$msmq,
	$QueueACL = ""
	)
	$Domain = ((Get-WmiObject win32_computersystem).domain -replace "\..*","").tolower()
	$Computername = $Computername.substring(0,1).toupper()+$Computername.substring(1).tolower()
	$QueuePath = "$Computername\$Queue`_$Domain"
	"Checking for $QueuePath"
	if ($msmq::exists($QueuePath)) {
		"$QueuePath exists.  We are going to delete it"
		$msmq::delete($QueuePath)
		}
	"Creating $QueuePath"
	$Q = $msmq::Create($QueuePath)
	$Q.UseJournalQueue = $TRUE
	$Q.MaximumJournalSize = 2048
	$Q.Label = "$Queue`_$Domain"
	$q.SetPermissions("$Domain\svc_comservice", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Set)
	$q.SetPermissions($QueueACL, [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Set)
	$q.SetPermissions("Anonymous Logon", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Revoke)

	}

Import-Module servermanager
if ((Get-WindowsFeature msmq).installed) {


	echo "Loading System.Messaging..."
	[Reflection.Assembly]::LoadWithPartialName( "System.Messaging" )
	$msmq = [System.Messaging.MessageQueue]
	
	# Depending on the switch we will need to construct the QueuePath names different since distributors don't
	# contain the servername in it and the target computer may be a clustered servername

	#$msmq::exists("computername\queue_name")
	# how to check if queue exists

	if ($SipReceiver) {
		# If you need to add more queue names just add them below and put a space between the names

		$SipQueues = "InitiateCall","InitiateCallRecording","InitiateReminderCall","TerminateCall"
		foreach ($Queue in $SipQueues) {
			Redo-ReceiverQueues -computername $Computername -queue $Queue -QueueACL "Domain Computers" -msmq $MSMQ
			}
	}
	
	if ($Distributor) {
		# If you need to add more queue names just add them below and put a space between the names
		$DistributorQueues = Write-Output ConvertFile ConvertFileAvailable InitiateCallAvailable InitiateCall `
			InitiateCallRecordingAvailable InitiateCallRecording InitiateReminderCallAvailable InitiateReminderCall `
			NonPaymentMailAvailable NonPaymentMail OfferMailAvailable OfferMail PartnerNotifyAvailable PartnerNotify `
			PaymentMailAvailable PaymentMail SystemEmailAvailable SystemEmail SystemEmailEventAvailable `
			SystemEmailEvent TerminateCallAvailable TerminateCall
		foreach ($Queue in $DistributorQueues) {
			Redo-DistributorQueues -Computername $Computername -Queue $Queue -QueueACL "Domain Computers" -MSMQ $msmq
			}
	}
	
	if ($MSMQReceiver) {
		# If you need to add more queue names just add them below and put a space between the names
		$MSMQQueues = Write-Output PartnerNotify PartnerNotifyRetry SystemEmailSystemEmailRetry PaymentMail `
			PaymentMailRetry NonPaymentMail NonPaymentMailRetry OfferMail OfferMailRetry SystemEmailEvent SystemEmailEventRetry `
			TerminateCall TerminateCallRetry ConvertFile ConvertFileRetry
		foreach ($Queue in $MSMQQueues) {
			Redo-ReceiverQueues -computername $Computername -queue $Queue -QueueACL "Domain Computers" -msmq $MSMQ
			}	
	}
	
	#$q.SetPermissions("DOMAIN\user", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Revoke)
	}
else {
	"MSMQ is not installed on this computer so we can't create queues from this machine"
	}


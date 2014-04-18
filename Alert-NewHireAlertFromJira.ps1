# This script has been sanitized so it probably does not make sense.  It was a script used to read JIRA tickets through 
# the REST API and send out email alerts if tickets were not being taken care of by a certain date.


<#
   	.Synopsis
	This script will search HR project for new hires.  If the status is HR or In Progress and the start date is
	less than 3 days away.  Then an email will be sent to onboardinghrteam@yp.com alerting them of the ticket and
	include a link to the ticket.
	
	This script runs on --- as a scheduled tasks once a day at 9am.
   	.Example
    Alert-NewHireAlertFromJira.ps1
	
   .Notes
    NAME: New-ADVendorUsersFromJira.ps1
    AUTHOR: tyoung
    LASTEDIT: 2/12/2013
    KEYWORDS: http://jira.com/browse/CS-1712
#Requires -Version 3.0
#>
[cmdletbinding(SupportsShouldProcess=$True)]
Param()

Set-StrictMode -Version 3	

#Function to email out alert message
<#
To: ---
Subject: ACTION REQUIRED! Employee start date approaching!
Body:
An employee is starting in 3 days or less.
The HR Jira ticket is currently assigned to HR or the Hiring Manager.
Please make sure this ticket is submitted to User Support and Facilities right away!
HR Ticket: <Insert link to that Jira ticket>
#>

# This is for sending emails for those with start dates of 3 or less, this includes those with start dates
# that have already passed by, but not the ones that have no start date field at all

function Send-AlertEmail {
	[cmdletbinding(SupportsShouldProcess=$True)]
	Param (
	$Subject = "ACTION REQUIRED! Employee start date approaching!",
	$Link
	)

$smtpserver = "10.1.92.42"
$SendTo = "---"
#$SendTo = "---"
$From = "---"
$Body = @"
An employee is starting in 3 days or less, or the start date has already passed.
The HR Jira ticket is currently assigned to HR or the Hiring Manager.
Please make sure this ticket is submitted to User Support and Facilities right away!
HR Ticket: $Link
"@


Send-MailMessage -To $SendTo -From $From -Subject $Subject -Body $Body -SmtpServer $smtpserver 

}

function Send-AlertEmail-NoStartDate {
	[cmdletbinding(SupportsShouldProcess=$True)]
	Param(
	$Subject = "ACTION REQUIRED! Employee nas no start date!",
	$Link
	)
	
$smtpserver = "---"
$SendTo = "---"
#$SendTo = "---"
$From = "---"
$Body = @"
An employee in a JIRA ticket has no start date field.
The HR Jira ticket is currently assigned to HR or the Hiring Manager.
Please make sure this ticket is submitted to User Support and Facilities right away!
HR Ticket: $Link
"@


Send-MailMessage -To $SendTo -From $From -Subject $Subject -Body $Body -SmtpServer $smtpserver 

	
}

$SearchURL = @"
http://jira.---.com/rest/api/2/search?jql=project %3D HR AND issuetype in (NPW-Consultant%2C NPW-Contractor%2C "New Hire") AND status in (HR%2C "Waiting for Assignee")&os_username=---&os_password=---
"@

$Issues = Invoke-RestMethod -Uri $SearchURL

# Start date is customfield_10434
foreach ($Issue in $Issues.issues) {

	if($Issue.fields.customfield_10434) 
		{
		$StartDate = Get-Date $Issue.fields.customfield_10434
		$Today = Get-Date
		$StartDate - $today | select -ExpandProperty Days
		if (($StartDate - $today | select -ExpandProperty Days) -le 3) 
			{
			# Less than 3 days left so let's send out the email
			Write-Verbose "YES less than 3 days left for $($issue.key)"
			$Link = "Http://jira.---.com/browse/$($issue.key)"
			Write-Verbose "Sending email about $Link"
			Send-AlertEmail -Link $Link
			}
			
		}
	else
		{
		# We couldn't find a value for start date so let's just send out an email regarding this ticket
		Write-Verbose "NO start date found for $($issue.key)"
		$Link = "Http://jira.---.com/browse/$($issue.key)"
		Write-Verbose "Sending email about $link"
		Send-AlertEmail-NoStartDate -Link $Link
		}
}

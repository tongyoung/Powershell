<#
   .Synopsis
	This searches the known blades to find whatever computername is given as an argument and will 
	return some variables for that blade.  More data can be added if needed.
	It only works on serverx because there is an HP module installed there.  If you 
	want to install the cmdlets somewhere else, they can be downloaded from 
	https://h20392.www2.hp.com/portal/swdepot/displayProductInfo.do?productNumber=HPSCOMBMP
   .Example
    Get-BladeInfo.ps1 -computername serverxxx
		
	ServerName   : SERVERxxx
	Enclosure    : BLD05
	BayNumber    : 11
	Powered      : On
	MPDnsName    : SERVERxxx-ilo
	MPIpAddress  : 10.x.x.x
	SerialNumber : --scrubbed--
	Model        : ProLiant BL460c G5
	
   .Example
    Get-BladeInfo.ps1 -computername serverxxx,serveryyy
	
	ServerName   : SERVERxxx
	Enclosure    : IRVBLD01
	BayNumber    : 6
	Powered      : On
	MPDnsName    : SERVERxxx-ilo
	MPIpAddress  : 10.x.x.x
	SerialNumber : --scrubbed--
	Model        : ProLiant BL460c G6

	ServerName   : SERVERyyy
	Enclosure    : IRVBLD02
	BayNumber    : 6
	Powered      : On
	MPDnsName    : SERVERyyy-ilo
	MPIpAddress  : 10.x.x.x
	SerialNumber : --scrubbed--
	Model        : ProLiant BL460c G6

   .Parameter COMPUTERNAME
    This can be one or many comma separated names. Required parameter.
   .Notes
    NAME: Get-BladeInfo.ps1
    AUTHOR: tyoung
    LASTEDIT: 9/7/2012
    KEYWORDS:
#Requires -Version 2.0
#> 

param (
[String[]]$Computername = ""
)

# We will see if the HP Cmdlets are loaded yet, and if not we will load them.  If this fails then we will error out
# of the script

if ( (Get-PSSnapin HewlettPackard.Servers.BladeSystem.HPBladeSystemEnclosureCmdLets -ErrorAction SilentlyContinue) -eq $null )
	{
	try 
		{
		Add-PSSnapin HewlettPackard.Servers.BladeSystem.HPBladeSystemEnclosureCmdLets -ErrorAction Stop
		Write-Host "Loading HP Blade Enclosure Cmdlets"
		}		
	catch 
		{
		Write-Warning "HP Blade Enclosure Cmdlets not found, script won't work.  Please try on irvncascom01.nca.keen.com"
		break
		}
	}

		$hash = @{}
		
		# Enclosures are only identified by serial number from get-blade, so we need to create a hash table of which
		# serial numbers go to which enclosures and then we can lookup the values later
		
		Get-Enclosure | foreach { $hash.add($_.SerialNumber,$_.EnclosureName) }

		# We only took a few of the possible values from get-blade.  There are more and they could easily be added to
		# the script.  The only value you cannot pull is how much memory is in the blade.
		
		$computername | foreach {
			$bladename = $_
			$blade = $null
			$blade = Get-Blade | Where-Object {$_.Servername -eq $bladename} | 
				select Servername, @{l="Enclosure";e={$hash.item($_.EnclosureSerialNumber)}}, 
				BayNumber, Powered, MPDnsName, MPIpaddress, SerialNumber, @{l="Model";e={$_.Name}}
			if (!($blade))
				{
				# Add a fall back in case servername not found, try to find my ilo name
				$blade = get-blade | Where-Object {$_.mpdnsname -match $bladename} |
					select Servername, @{l="Enclosure";e={$hash.item($_.EnclosureSerialNumber)}}, 
					BayNumber, Powered, MPDnsName, MPIpaddress, SerialNumber, @{l="Model";e={$_.Name}}				
				}
			if (!($blade))
				{
				Write-Host "$bladename could not be found"
				}
			else
				{
				$blade
				}

			}
	
# SIG # Begin signature block
# MIIaQwYJKoZIhvcNAQcCoIIaNDCCGjACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUU6g1IEMeEUh14zVs4z11XR5n
# stqgghWNMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggZzMIIFW6ADAgECAhMbAAA+K87Xy0jE2WLJAAYAAD4rMA0GCSqGSIb3DQEBBQUA
# MFkxEzARBgoJkiaJk/IsZAEZFgNjb20xEjAQBgoJkiaJk/IsZAEZFgJ5cDEUMBIG
# CgmSJomT8ixkARkWBGNvcnAxGDAWBgNVBAMTD2NvcnAtQ0EwMS1QS0kwMTAeFw0x
# MzAzMjcxODM4MjVaFw0xNDAzMjcxODM4MjVaMIGGMRMwEQYKCZImiZPyLGQBGRYD
# Y29tMRIwEAYKCZImiZPyLGQBGRYCeXAxFDASBgoJkiaJk/IsZAEZFgRjb3JwMQ8w
# DQYDVQQLEwZQZW9wbGUxHzAdBgNVBAsTFkRvbWFpbiBNaWdyYXRpb24gVXNlcnMx
# EzARBgNVBAMTClRvbmcgWW91bmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQD4s4QTwUgwmNy/aC4XPMU8GnxC0ls29nZVy6ak/gYnIi7WQQsvt9gnfDfz
# Qa+z5hdCwPyhVvVpahmhG/VX/iLcy7che3eEfYOze03Wi0B8+zPUXoEj9GHBhitl
# 3950AEs75XtUz3NvRhDqoZ1NlT2AGbMmRBeCsrYuBSCiOTzL5lm86yqs/TNQeuSG
# NsADK92HVzkOj6+/abmg5WnNVmCdkX7Lik3urVyC9UCtXXzinm75EkNHn4QgdvTD
# 98WuaN6KH3WvPsytjufJzzPWnIexUzvTIRxBY3e5BuJOi+MwJbCvYAX560YSYbIx
# zXM/j7II+UvDduJRABB+Phuy9RKfAgMBAAGjggMEMIIDADAlBgkrBgEEAYI3FAIE
# GB4WAEMAbwBkAGUAUwBpAGcAbgBpAG4AZzATBgNVHSUEDDAKBggrBgEFBQcDAzAO
# BgNVHQ8BAf8EBAMCB4AwHQYDVR0OBBYEFC+/AezyQ4tbt20EQqLrXi8xBUMBMB8G
# A1UdIwQYMBaAFBqoY2XLX3FLMa4pgFQ9Qe0wE5V7MIIBFwYDVR0fBIIBDjCCAQow
# ggEGoIIBAqCB/4Y/aHR0cDovL2NhMDEtcGtpMDEuY29ycC55cC5jb20vQ2VydEVu
# cm9sbC9jb3JwLUNBMDEtUEtJMDEoNikuY3JshoG7bGRhcDovLy9DTj1jb3JwLUNB
# MDEtUEtJMDEoNiksQ049Y2EwMS1wa2kwMSxDTj1DRFAsQ049UHVibGljIEtleSBT
# ZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWNvcnAsREM9
# eXAsREM9Y29tP2NlcnRpZmljYXRlUmV2b2NhdGlvbkxpc3Q/YmFzZT9vYmplY3RD
# bGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludDCCASYGCCsGAQUFBwEBBIIBGDCCARQw
# ga0GCCsGAQUFBzAChoGgbGRhcDovLy9DTj1jb3JwLUNBMDEtUEtJMDEsQ049QUlB
# LENOPVB1YmxpYyBLZXkgU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJh
# dGlvbixEQz1jb3JwLERDPXlwLERDPWNvbT9jQUNlcnRpZmljYXRlP2Jhc2U/b2Jq
# ZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1dGhvcml0eTBiBggrBgEFBQcwAoZWaHR0
# cDovL2NhMDEtcGtpMDEuY29ycC55cC5jb20vQ2VydEVucm9sbC9jYTAxLXBraTAx
# LmNvcnAueXAuY29tX2NvcnAtQ0EwMS1QS0kwMSg2KS5jcnQwLQYDVR0RBCYwJKAi
# BgorBgEEAYI3FAIDoBQMEnR5b3VuZ0Bjb3JwLnlwLmNvbTANBgkqhkiG9w0BAQUF
# AAOCAQEAU+gdmfdc5FNjMfAPtd/kZGVbJP26qkrjbjcaJacgUj5TJ/ClDJzw6Gay
# LJe8qWR7yue612kGbxzOvFM00R3QvdLX689A+M38JcKgevCEP1W98pxEP3IMaOTR
# MIIK/a708omNRQlKTB1PPL1+9cPiF6y3M5DnG+4ahQfx1Fkkpn+qlgDrAvg3qIqi
# DcQNseB3VzdLTPFMYAVl9fkIzB9rdiyQ1epAzaWGPPiElkJXrBT+aKz9CZiJzlM1
# uWvTQerL1KDZ5nrneTrV0hnAZo3quf26zRuhCSozGdVUxR6Z3T0rhQzlYXujoAWm
# 2ZaXrjr0+22pOMNMerniQo+lgrNoXjCCBnkwggVhoAMCAQICEycAAAAJyhGI/eqg
# 1JAAAAAAAAkwDQYJKoZIhvcNAQEFBQAwbTELMAkGA1UEBhMCVVMxDzANBgNVBAoT
# BllQLmNvbTEgMB4GA1UECxMXQ29ycCBTeXN0ZW1zIERlcGFydG1lbnQxKzApBgNV
# BAMTIllQLmNvbSBDQTAxIE9mZmxpbmUgUm9vdCBBdXRob3JpdHkwHhcNMTMwMzA4
# MDQzMTI0WhcNMjMwMzA4MDQ0MTI0WjBZMRMwEQYKCZImiZPyLGQBGRYDY29tMRIw
# EAYKCZImiZPyLGQBGRYCeXAxFDASBgoJkiaJk/IsZAEZFgRjb3JwMRgwFgYDVQQD
# Ew9jb3JwLUNBMDEtUEtJMDEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQD7O6nMbTZmOkHqfX6VYYg5TvXKQ1kBjVVmKk+Nh3UyEl944PrNo/VdrlDdsKpJ
# Z0+K9WEIY57thZT47dD9lxjDU8AfBPOjYkvlYrQQz9JleRK/bdOmVq3GpixB30Ym
# Wo4fdQRO9fgeWH7NLijGTQpfofMkkW0GgZcYycEuGpK3FMxT8gKcqfUTN9LQ+GEB
# dcYcxUK1Y8Rva5oBFpAK6a2/bKnSvnOkgtbpTGdGnKXt8BLvZl+7mhd68clri16n
# 4c6kiua4+i4ETUdTQooe/6tkBnsA6QkQd5SRNuOs9cT8VClgIFWNi8BXXBSwe5/3
# B7RJrRUBXpMIxySvuCREVUSNAgMBAAGjggMkMIIDIDASBgkrBgEEAYI3FQEEBQID
# BgAGMCMGCSsGAQQBgjcVAgQWBBRyJhkvElwgGCD+/VnnxlbHP/7x6zAdBgNVHQ4E
# FgQUGqhjZctfcUsxrimAVD1B7TATlXswGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBD
# AEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAUYDAd
# ECQkAA4KFEKRLsWk44INvvEwggE2BgNVHR8EggEtMIIBKTCCASWgggEhoIIBHYZN
# aHR0cDovL3BraS1yb290LmNvcnAueXAuY29tL0NlcnRFbnJvbGwvWVAuY29tIENB
# MDEgT2ZmbGluZSBSb290IEF1dGhvcml0eS5jcmyGgctsZGFwOi8vL0NOPVlQLmNv
# bSBDQTAxIE9mZmxpbmUgUm9vdCBBdXRob3JpdHksQ049Y2EwMS1wa2kwMixDTj1D
# RFAsQ049UHVibGljIEtleSBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1
# cmF0aW9uLERDPWNvcnAsREM9WVAsREM9Y29tP2NlcnRpZmljYXRlUmV2b2NhdGlv
# bkxpc3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludDCCATAG
# CCsGAQUFBwEBBIIBIjCCAR4wWQYIKwYBBQUHMAKGTWh0dHA6Ly9wa2ktcm9vdC5j
# b3JwLnlwLmNvbS9DZXJ0RW5yb2xsL1lQLmNvbSBDQTAxIE9mZmxpbmUgUm9vdCBB
# dXRob3JpdHkuY3J0MIHABggrBgEFBQcwAoaBs2xkYXA6Ly8vQ049WVAuY29tIENB
# MDEgT2ZmbGluZSBSb290IEF1dGhvcml0eSxDTj1BSUEsQ049UHVibGljIEtleSBT
# ZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWNvcnAsREM9
# WVAsREM9Y29tP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZp
# Y2F0aW9uQXV0aG9yaXR5MA0GCSqGSIb3DQEBBQUAA4IBAQBOCj3v9YNQflM2kKXv
# +sg9ikwLetJrO9MF9SOzzgbKSlVK0APwb2eLgSeIfc1AM4Z3fizBHtIprm04v3DE
# qQiOjsuZ7TnFaaHRvqdPE4Wu8FmlQVmEaygNYDrBYXTmXvLnjjne0m/ss3xRtqbz
# A/c96FgdM8PWRQBzxQYrgb65TVIKgLUJ/4tCLGRN6iP+tolbqUQ185xgCum9qjf9
# nvqV/lV3ljlJ3b228KYguPEv3X66y4ihTEv1s4Vbfu7oQliRVLMGJ7F2dxD62BA9
# UhRnZ1EhBniwuhRE4shfwexv9i6rOH0JLwo76Ym/NyOhWMvphat1tY5wVk+SuyIp
# 0EaiMYIEIDCCBBwCAQEwcDBZMRMwEQYKCZImiZPyLGQBGRYDY29tMRIwEAYKCZIm
# iZPyLGQBGRYCeXAxFDASBgoJkiaJk/IsZAEZFgRjb3JwMRgwFgYDVQQDEw9jb3Jw
# LUNBMDEtUEtJMDECExsAAD4rztfLSMTZYskABgAAPiswCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FHKuqVrNh1bs8rq5XDfJcwoa3J8KMA0GCSqGSIb3DQEBAQUABIIBAOuvH8XGSZqx
# eIkmMMnVUn2GsbRPhuAiIgEtMYKgNmKfbHVs3qDcywBqErA7EaM7UH6sr4hVJztm
# CnQR0N6nGXFy6v9Ee5RGjo2Hw1xrAPSobWz6EDRh03jE/R4t5CJM737z9ciiycqd
# YHoOG3lCNl8m7FoO3Hc/dFH6r6SthfXq5YgOY8hrKm7v0LkfujU26gkrgv+ua8L/
# Ta6IYzfI1LSqpANP/hUBlamjWezGa0xMPlI+GblsaGOo++t/5cI/+R056MMO/zhM
# oGNZURG8gKHXFDbbzfzQBQnqRN1bDXXWNbqQw3ytI1xGEv9L2VzZaeeJeivx2n68
# Mkp5u7/iG+GhggILMIICBwYJKoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQswCQYD
# VQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMT
# J1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0OMj+
# vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEH
# ATAcBgkqhkiG9w0BCQUxDxcNMTMwNDA1MjEyMjQzWjAjBgkqhkiG9w0BCQQxFgQU
# uxVYEsPfd4Ds5iRwGsqDQQTDoQAwDQYJKoZIhvcNAQEBBQAEggEAhPotA9YOYRpp
# QugiAz7A+KptDaGbRtvRGuKVWwOvT8AOK17Rn5glMCi2hm6XPCcObNb4HlJq7ePK
# P8X21mKgecUUa6tgK8sP+fJrvIodGB4L8JnVWwqYxlvhRhUW4zlt0ZhBabX/eDAZ
# /JebmhBRl0ef9NuhYO7UqhBQ+z0xixdT7W0Xao2hEPbrMoFCFRFE2MIVv/U5ZrBh
# zDVcOLsGm1yzHD06VRBah0O3DBLa5hl9HuZLmaXskbGEY0luoxH04Kmk+et4X8kt
# OnQO/qpmOzEdTpvV2TYwQ/zukBiGCNOvN/UKz8B9JcNOJWs7rCV/EYSkB3AwytNL
# fLguX9IAZw==
# SIG # End signature block

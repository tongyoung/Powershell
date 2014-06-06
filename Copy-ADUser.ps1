<#
   .Synopsis
    This just copies a user and creates a new user in the same OU with the same group membership
   .Example
    Copy-ADUser.ps1 -Copy tong -Fullname "John Doe" -password "blahblah"
   .Parameter COPY
    This is the samaccountname of the user you want to copy
   .Parameter FULLNAME
    This is the full name of the user account you want to create
   .Parameter PASSWORD
    This is the initial passsword you want to set for the user
   .Notes
    NAME: Copy-ADUser.ps1
    AUTHOR: tyoung
    LASTEDIT: 1/15/2013
    KEYWORDS:
#Requires -Version 2.0
#> 

param(
[Parameter(Mandatory=$true,Position=0)]$Copy,
[Parameter(Mandatory=$true,Position=1)]$FullName,
[Parameter(Mandatory=$true,Position=2)]$password
)

Import-Module activedirectory

# Let's get the object for the user we want to copy
# Should add some kind of check in here for a valid user
# We don't use -Properties * here, because if you try to copy the SID it throws an error
$Instance = Get-ADUser -Identity $Copy -Properties DistinguishedName,MemberOf

$password = ConvertTo-SecureString $password -AsPlainText -Force
$domain = (Get-WmiObject win32_computersystem).domain

# Get the OU of the user we are copying, we will use this as the path for the new user
# We grab the DN of the user and then edit out the first part so we just get a path
$path = ($Instance | Select-Object -ExpandProperty DistinguishedName) -replace "CN(.*?),",""

# Get first name
$split = $FullName -split " "
$Firstname = $split[0]

# Get last name
$Lastname = $split[1]

# Construct username
$Username = $Firstname.substring(0,1) + $Lastname

# Create the user
New-ADUser -Surname $Firstname -GivenName $Lastname -SamAccountName $Username -Path $path `
	-AccountPassword $password -ChangePasswordAtLogon $true -Name $FullName -Instance $Instance `
	-UserPrincipalName ($UserName + "@" + $domain)
	
# Should check here if the user is valid before trying to enable the account
Enable-ADAccount $Username

# Copy the group membership to the new user
$Instance.MemberOf | foreach {Get-ADGroup $_ | Add-ADGroupMember -Members $Username}


param(
    [string[]]$Computername
)

@out = @()
foreach ($computer in $Computername) {
    $os = Get-CimInstance -Computername $computer -ClassName win32_operatingsystem
    $cs = Get-CimInstance -Computername $computer -ClassName win32_computersystem
    $properties = @{
        Computername = $Computer
        OSVersion = $os.servicepackmajorversion
        Model = $cs.model
        Mfgr = $cs.Manufacturer}
    $obj = New-Object -TypeName PSObject -Property $properties
    $out += $obj
}

$out
# Don't do things like this.  Let powershell output the data to the stream.  The only time you might want to do this and collect all the data first is if you need to do something like a sort.

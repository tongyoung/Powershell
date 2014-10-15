########################################################################################################
#                                                                                                      #
#  Just simple script to make hashtable of windows update according to windows version and apply patch #
#                                                                                                      #
########################################################################################################

$VersionHash = @{ 
    "6.0-32-bit" = "Windows6.0-KB3000869-x86.msu";
    "6.0-64-bit" = "Windows6.0-KB3000869-x64.msu";
    "6.1-64-bit" = "Windows6.1-KB3000869-x64.msu";
    "6.2-32-bit" = "Windows8-RT-KB3000869-x86.msu";
    "6.2-64-bit" = "Windows8-RT-KB3000869-x64.msu";
    "6.3-32-bit" = "Windows8.1-KB3000869-x86.msu";
    "6.3-64-bit" = "Windows8.1-KB3000869-x64.msu";
    }

$Install_Dir = "c:\temp"

$version = ((Get-CimInstance win32_operatingsystem).version).substring(0,3)
$bit = (Get-CimInstance win32_operatingsystem).osarchitecture

invoke-expression "c:\windows\system32\wusa.exe $install_dir\$($VersionHash.item("$version-$bit"))"

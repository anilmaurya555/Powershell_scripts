# process commandline arguments
[CmdletBinding()]
Param ([array]$ServerNames)
$mytable = Import-CSV -Path c:\anil\cmdb_inventory_0730.csv | Group-Object -AsHashTable -Property "u_server"

foreach ( $server in $ServerNames){
                                $mytable["$server"]."u_server"  
                                $mytable["$server"]."u_server.ram"       
                                $mytable["$server"]."u_server.po_number"
                                $mytable["$server"]."u_server.disk_space"
                                write-host "================================"
                                 }
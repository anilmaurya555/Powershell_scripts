$file= get-content c:\anil\scripts\dups.txt
$servers= @()
foreach ( $server in $file ){
                             $newserver = $server.tolower()
                                  if ( $newserver -notin $servers) {
                                           $servers += $newserver} else
                                                   {
                                                     Write-host "Server "$newserver " is Dups"
                                                     }
                            }
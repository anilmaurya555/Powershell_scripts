$DebugPreference = 'Continue'
$lines = gc "c:\anil\scripts\dups.txt"
$ddlines = gc  "c:\anil\scripts\pool_dd.txt"
$outFile = 'output.txt'
$clients = @{}
$dds = @{}
### get report

foreach ( $line in $ddlines) {
                   $pool = $line.split("	")[0]
                   $dd = $line.split("	")[1] 
                      if ($pool -notin $dds.keys) {
                                   
                                  $dds[$pool] = $dd
                                               }
                            }

foreach ($line in $lines){
                         $pool = $line.split(" ")[0]
                         $client = $line.split(" ")[4]
                         $db = $line.split(" ")[6]
                         $dd = $dds[$pool]
                         $vars = @"
  `n
    `$line = $line
    `$client = $client
    `$pool = $pool
    `$db = $db
    `$dd = $dd
"@
#Write-Debug $vars
                         
                        if($client -notin $clients.Keys){
                                                        $clients[$client] = @{}
                                                        $clients[$client]['pool'] = "$pool "
                                                        $clients[$client]['db'] = "$db "
                                                        $clients[$client]['dd'] = "$dd "
                                                         }else{
                                                        if ("$pool " -notin $clients[$client]['pool']) {$clients[$client]['pool'] += "$pool "}
                                                        if ("$db "  -notin $clients[$client]['db']) {$clients[$client]['db'] += "$db "}
                                                        if ("$dd " -notin $clients[$client]['dd'] ) {$clients[$client]['dd'] += "$dd "}
                                                       }
                            }


$clients.GetEnumerator() | Sort | ForEach-Object {
    "{0},{1},{2},{3}" -f ( $_.Name ,$_.Value.pool,$_.Value.db,$_.Value.dd)| Out-File -FilePath $outFile -Append
    
}


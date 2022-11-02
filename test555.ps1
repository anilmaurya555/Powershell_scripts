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
                        if($client -notin $clients.Keys){
                                                        $clients[$client] = @{
                                                        'pool' = @()}
                                                        $clients[$client]['db'] = @{
                                                        'db' = @()}
                                                        $clients[$client]['dd'] = @{
                                                        'dd' = @()}
                                                        $clients[$client].pool = $pool
                                                        $clients[$client].db = $db
                                                        $clients[$client].dd = $dd
                                                         }else{
                                                         $poolCheck = $pool | Where-Object -FilterScript { $_ -notin $clients[$client]['pool']}
                                                            if($poolcheck.Count -gt 0){
                                                                                    $clients[$client]['pool'] += $poolCheck
                                                                                      } else {
                                                                                        "Nothing to add to pool"
                                                                                              }
                                                         $dbCheck = $db | Where-Object -FilterScript { $_ -notin $clients[$client]['db']}
                                                            if($dbcheck.Count -gt 0){
                                                                                    $clients[$client]['db'] += $dbCheck
                                                                                      } else {
                                                                                        "Nothing to add to db"
                                                                                         }
                                                         $ddCheck = $pool | Where-Object -FilterScript { $_ -notin $clients[$client]['dd']}
                                                            if($ddcheck.Count -gt 0){
                                                                                    $clients[$client]['dd'] += $ddCheck
                                                                                      } else {
                                                                                        "Nothing to add to dd"
                                                                                         }                                                    
                                                        
                                                       }
                            }

$clients.GetEnumerator() | Sort | ForEach-Object {
    "{0},{1},{2},{3}" -f ( $_.Name ,$_.Value.pool,$_.Value.db,$_.Value.dd)| Out-File -FilePath $outFile -Append
    
}
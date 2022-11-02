$lines = gc "c:\anil\scripts\dups.txt"
$ddlines = gc  "c:\anil\scripts\pool_dd.txt"
$outFile = 'output.txt'
$clients = @{}
$clientsdb = @{}
$clientsdd = @{}
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
$clients[$client] = "$pool "
$clientsdb[$client] = "$db "
$clientsdd[$client] = "$dd "
}else{
               if ($pool -notin ($clients.values)  ) {$clients[$client] += "$pool "}
               if ($db -notin ($clientsdb.values) ) {$clientsdb[$client] += "$db "}
               if ($dd  -notin ($clientsdd.values) ) {$clientsdd[$client] += "$dd "}
}
}

foreach ($client in ($clients.Keys | Sort-Object )){
"$client,$($clientsdb[$client]),$(($clients[$client] | Sort-Object) -join ','),$(($clientsdd[$client] | Sort-Object) -join ',')" | Out-File $outFile -Append
}


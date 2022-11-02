$clients = get-content "c:\anil\scripts\good_clients.txt"
$outFile = 'all_avamar_dedup_0820_0824_good.txt'

foreach($client in $clients){
    
    $content = get-content "c:\anil\scripts\all_avamar_dedup_0820_0824.txt"
      foreach ($line in $content ){
      
                 if ($line.contains("$client" )) { 
             $line | Out-File -FilePath $outFile -Append
             
                     }
    }
}

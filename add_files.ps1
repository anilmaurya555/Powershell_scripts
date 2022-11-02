$outFile = 'output_0815.txt'
$servers = ("MNBAMR303P","MNBAMR302P","PPBAMR302P","JCBAMR300P")

foreach($server in $servers){
    $txtfile = "c:\anil\scripts\$($server)_dedup_0820_0824.txt"
    $clients = get-content $txtfile
      foreach ($line in $clients ){
             $newline = "$server |" + $line        
             $newline | Out-File -FilePath $outFile -Append
                     }
    
}

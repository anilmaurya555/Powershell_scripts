$ddlines = gc  "c:\anil\scripts\pool_dd.txt"
$outFile = 'output.txt'
$dds = @{}
$newpool = @()
### get report
foreach ( $line in $ddlines) {
                   $pool = $line.split("	")[0]
                   $dd = $line.split("	")[1] 
                              if ($pool -notin $dds.keys) {
                                  $dds[$pool] = @{} 
                                  $dds[$pool]['dd'] = $dd
                                               }
                            
                            }
                            #$dds.GetEnumerator() |% {"{0,-25}  {1,-10}" -f $_.name,$_.value.dd}
                           
                            $dds["MN_WFULL"].value
                            

                            
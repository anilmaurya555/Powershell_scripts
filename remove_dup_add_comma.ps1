#$outFile = get-content "C:\anil\scripts\dups.txt"
$outFile = get-content "C:\anil\scripts\Networker_0419_2021_Output.txt"
$NewFile = Join-Path -Path $PSScriptRoot -ChildPath "new_output_Networker_0419_2021_Output.txt"
$pool2 = ""
$client2 = ""
$clntpool = @()
ForEach ($line in $outfile) {
                   $pool1 = $line.split(",")[1]
                   $client1 = $line.split(",")[4]
                   $backupt =  ($line.split(",")[8]).split(":")[0]
                    $db = ('RMAN','DB2')
                    if ($backupt -in $db) { $data = $backupt}else {$data = "File"}
                        if ( $($pool1) -notlike $($pool2) -or $($client1) -notlike $($client2)){
                                    
                                   $newline = "$($pool1)    $($client1)  $($data)"
                                        if ($newline -notin $clntpool){
                                             $clntpool += $newline
                                             }
                                   #" {0,15}  {1,15}" -f $pool1 ,$client1
                                      
                                       }

                               $pool2 = $pool1
                               $client2 = $client1
                                        
                   }
                   $clntpool|Tee-Object -FilePath $NewFile
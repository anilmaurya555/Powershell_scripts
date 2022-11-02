$lines = get-content c:\anil\scripts\dups.txt
$outfile = $(Join-Path -Path $PSScriptRoot -ChildPath output.txt)
Clear-Content $outfile
$newlines = @()
foreach ( $line in $lines){
             
             $newlines += $line

             if ($line.contains('DDS')) {
                          
                          $newlines += $line
                          $total = $newlines.length
                          $i = 0
                          foreach ($newline in $newlines){
                                                $i ++
                                                if ( $newline.contains('name')){
                                                                     $name=$newline.split(":")[1].trim(";")
                                                                                }
                                                if ( $newline.contains('DD')){
                                                                     $DD=$newline.split(":")[1]
                                                                       
                                                                     }
                                                

                                                                                                                     
                                                                                                        
                                                              if ( $total -eq  $i ){
                                                                                         
                                                                "{0,15}       {1,20}" -f ($name, $DD) | Out-File -FilePath $outFile -Append
                                                                                                   
                                                                                                    }
                                                                                       
                                                                            }
                                                                            $newlines = @()
                            }
                            }
                                   
                                                       
$lines = get-content c:\anil\scripts\input.txt
$outfile = $(Join-Path -Path $PSScriptRoot -ChildPath output.txt)
Clear-Content $outfile
$newlines = @()
foreach ( $line in $lines){
             
             $newlines += $line

             if ($line.contains('client OS type')) {
                          
                          $newlines += $line
                          $total = $newlines.length
                          $i = 0
                          foreach ($newline in $newlines){
                                                $i ++
                                                if ( $newline.contains('name')){
                                                                     $name=$newline.split(":")[1].trim(";")
                                                                                }
                                                if ( $newline.contains('group')){
                                                                     $group=$newline.split(":")[1].trim(";")
                                                                       
                                                                     }
                                                if (! $newline.contains(':')){

                                                                      $group += $newline.trim(";").trim()
                                                                               }
                                                if ( $newline.contains('backup type')){
                                                                      $backuptype=$newline.split(":")[1].trim(";")
                                                                      }
                                                if ( $newline.contains('client OS type')){
                                                                      $ostype=$newline.split(":")[1].trim(";")
                                                                      }
                                                if ( $newline.contains('command')){
                                                                      $cmd=$newline.split(":")[1].trim(";")
                                                                      }      
                                                                                                        
                                                              if ( $total -eq  $i ){
                                                                                         
                                                                "{0}:{1}:{2}:{3}:{4}" -f ($name, $group, $backuptype,$ostype,$cmd) | Out-File -FilePath $outFile -Append
                                                                                                   
                                                                                                    }


                                                                                                                                     

                                                                            }
                                                                            $newlines = @()
                            }
                            }
                                                        
                            

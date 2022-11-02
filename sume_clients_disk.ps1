$file = get-content c:\anil\scripts\lpar_jc.txt

$server = @{}
foreach ( $line in $file) {
                          $name = $line.split("")[0]
                          
                          [int]$size = $line.split("")[1]
                          
                          if ($name -notin $server.keys) {
                                                  $server[$name] = @{}
                                                  $server[$name]['size'] = $size
                                                  
                                                     } else
                                                     {
                                                     $server[$name]['size'] += $size
                                                      }
                          }
                                                  
                         $server.GetEnumerator()|Sort-Object {$_.name} -Descending | ForEach-Object {"{0,-25}  {1,-10}" -f $_.name,$_.value.size}
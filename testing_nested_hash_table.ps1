$league = @{
   school = @{
      name = 'Lincoln High School' 
      levels = ('9','10','11','12')
      } 
   sports = @{
      football = @{ 
         coed = 'b'
         season = 'fall'
         balls = $true
      }
      hockey = @{ 
         coed = 'b'
         season = 'winter'
         balls = $false
      }
      lacrosse = @{ 
         coed = 'g'
         season = 'spring'
         balls = $true
      }
      swim = @{ 
         coed = 'c'
         season = 'winter'
         balls = $false
      }
   }
}

# $league = clusterstat   , scholl & sports   = clusters  , swim is job in sports 

$customers = ("anil","raju")
$dollors   = ('56','77')
write-host "($league['sports'].GetEnumerator().Where{$_.Value.Balls}).Count"
($league['sports'].GetEnumerator().Where{$_.Value.Balls}).Count

write-host "($league['sports'].GetEnumerator() | Where-Object {$_.Value.Balls}).Count"
($league['sports'].GetEnumerator() | Where-Object {$_.Value.Balls}).Count
 
 write-host "$sports.PSBase.Keys.Where{$sports[$_]['balls']}.Count"
 $sports = $league['sports']
$sports.PSBase.Keys.Where{$sports[$_]['balls']}.Count


if ('fishing' -notin $league['sports'].keys){
                         
                                      $league['sports']['fishing'] = @{ 
         coed = 'h'
         season = 'fall'
         balls = $true
      }   
                                }

write-host "($league['sports'].GetEnumerator().Where{$_.Value.Balls}).Count"
($league['sports'].GetEnumerator().Where{$_.Value.Balls}).Count
#$league |ConvertTo-Json

if ('cycling' -notin $league['sports'].keys){
                         
                                      $league['sports']['cycling'] = @{ 
         coed = 'h'
         season = 'fall'
         balls = $true                                                                                  
      }                             }

       $league['sports']['cycling']['clients'] = @{}   

      $incr = 0
      foreach ($customer in $customers){
                              
                               $league['sports']['cycling']['clients'][$customer]= $dollors[$incr]
                                                          $iincr++       
                                            }
      
      $league['sports']['cycling']['clients'].GetEnumerator()|foreach {
     "{0} {1}" -f $_.key,$_.value
      }
     "---------------"
     #$league |ConvertTo-Json -Depth 10
     
     <#
     $league.GetEnumerator()|foreach {
                               if ($_.key -eq 'sports'){
                                    #$_.value.cycling
                                    #$_.value.cycling.clients
                                   # $_.value.cycling.clients.keys
                                   # $_.value.cycling.clients.values

                                    $_.value.cycling.clients.GetEnumerator()|foreach {
                                    "{0} {1}" -f $_.key ,$_.value
                                    }

                                                    }
                                      
                                     

                                     }

#>
$league.GetEnumerator()|foreach {
"======================================"
$cluster = $_.key
$cluster
$jobs = @() 
foreach ($job in $_.value.keys){
                $jobs += $job
                
                        }
                        write-host "=="
                       $jobs

if ($jobs.count -gt 0){
foreach ($job in $jobs){
   
if (($league.$($cluster).$($job).clients.keys).count -gt 0){
                                 write-host "==22"
                                 $league.$($cluster).$($job).clients.GetEnumerator()|foreach {
     "{0} {1}" -f $_.key,$_.value
      }
                                       }
                      }
                      }
                        }


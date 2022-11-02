 $out=Get-Content C:\anil\scripts\test1.txt
$ht = @{}
$ht.bkt=@()
$arr = @()
$today = Get-Date
foreach ( $line in $out){
              $arr=$line.Split(" ")
              if ( $arr[0] -ne "nwsppl300p.corpads.local"){
              $mn=$line -csplit "incr|full|manual"
              $md=$mn[1] -split "\s{1,}"
              if ($line -match  '.*( backup |Clone_DR ).*') {$btype=$md[9]} else {$btype=$md[8]}
              if ($line -cmatch "DB2") { $type="DB2"} elseif ( $line -cmatch "RMAN") {$type="RMAN"} else {$type="File"}
              $date =$mn[1].split(" ")[2]
              $newdate=[Datetime]::ParseExact($date, 'MM/dd/yyyy', $null)
              $diff = New-TimeSpan -Start $today -end $newdate
              #### look for one year only ########
              if ( $diff.Days -lt 400 ) {
                   if ( $arr[12] -ne "Clone_DR") {
                        if ($arr[0] -notin $ht.keys){
                                                 $ht[$arr[0]] = @{}
                                                 $ht[$arr[0]]['size'] = $arr[1]
                                                
                                                 if ($btype -match "DB2") {
                                                                            
                                                                            $ht[$arr[0]]['Db2size'] = $arr[1]
                                                                             }
                                                                             if ($btype -match "RMAN") {
                                                                             
                                                                            
                                                                             $ht[$arr[0]]['RMANsize'] = $arr[1]} 
                                                                             
                                                                            if  ($btype -notmatch "RMAN" -and $btype -notmatch "DB2" ){
                                                                             
                                                                             $ht[$arr[0]]['Filesize'] = $arr[1]}
                                                 
                                                 } else {
                                                         
                                                       if ($arr[1] > $ht[$arr[0]]['size']) {
                                                          $ht[$arr[0]]['size']= $arr[1]
                                                          
                                                          }
                                                          #####
                                                          if ($btype -match "DB2" -and $arr[1] > $ht[$arr[0]]['Db2size'] ) {
                                                                            $ht[$arr[0]]['Db2size'] = $arr[1]
                                                                            
                                                                             }
                                                                             if ($btype -match "RMAN" -and $arr[1] > $ht[$arr[0]]['RMANsize']) {
                                                                             $ht[$arr[0]]['RMANsize'] = $arr[1]
                                                                             
                                                                             } 
                                                                             if  ($btype -notmatch "RMAN" -and $btype -notmatch "DB2" -and $arr[1] > $ht[$arr[0]]['RMANsize']){
                                                                             
                                                                             $ht[$arr[0]]['Filesize'] = $arr[1]}

                                                          ####
                                                    }
                                                    }  ###clone_dr
                                                    }   ###less than 400
                          } ### chcking for networker server
                          } #### looping thru file
write-host "=================================In MB ==============================================="
write-host "===ServerName==============OverAllsize======DB2size===========RMANsize========FileSize"
write-host "======================================================================================"
 $ht.GetEnumerator()|Sort-Object {$_.name} -Descending | ForEach-Object  {"{0,-25}     {1:n2}          {2:n2}            {3:n2}            {4:n2}" -f $_.name,$($_.value.size/1024/1024),$($_.value.Db2size/1024/1024),$($_.value.RMANsize/1024/1024),$($_.value.Filesize/1024/1024)}  

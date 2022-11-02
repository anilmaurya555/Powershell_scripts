#########################################manuplation of MMINFO ###############
######mminfo -avot -q "savetime >= '24 February 2022', savetime <= '24 March 2022'" -r client,totalsize,group,policy,workflow,level,sscreate,ssretent,clretent,device,family,nsavetime,action,sumsize,name,location
################################################################################3
$out=Get-Content C:\anil\networker\mminfo_0324_2022.txt
$ht = @{}
$arr = @()
$today = Get-Date
$outFile = $(Join-Path -Path $PSScriptRoot -ChildPath "Networker_7y_clients_$(get-date -UFormat '%Y-%m-%d-%H-%M-%S').csv")
"Server Nam:Overall Size in MB:DB2 Size in MB:RMAN Size in MB:File Size in MB:Groups Name:Backup Type" | Out-File -FilePath $outFile
foreach ( $line in $out){
              $arr=$line.Split(" ")
              if ( $arr[0] -ne "nwsppl300p.corpads.local"){
              $mn=$line -csplit "incr|full|manual" ### split on case sensitive on incr or full or manual
              $md=$mn[1] -split "\s{1,}"   ### split on more than one white space
              if ($line -match  '.*( backup |Clone_DR ).*') {$btype=$md[9]} else {$btype=$md[8]}
              $clientHostName,$null,$backupPlans = -split $mn[0] ### split mn[0] in three peice
              if ($line -cmatch  "incr" -and $line -cmatch  "DB2") {$bt="DB2incr"}
              if ($line -cmatch  "manual" -and $line -cmatch  "DB2") {$bt="DB2manual"}
              if ($line -cmatch  "full" -and $line -cmatch  "DB2") {$bt="DB2full"} 
              if ($line -cmatch  "incr" -and $line -cmatch  "RMAN") {$bt="RMANincr"}
              if ($line -cmatch  "manual" -and $line -cmatch  "RMAN") {$bt="RMANmanual"}
              if ($line -cmatch  "full" -and $line -cmatch  "RMAN") {$bt="RMANfull"} 
              if ($line -cmatch  "incr" -and $line -notmatch  "DB2" -and $line -notmatch  "RMAN") {$bt="Fileincr"}
              if ($line -cmatch  "manual" -and $line -notmatch  "DB2" -and $line -notmatch  "RMAN") {$bt="Filemanual"}
              if ($line -cmatch  "full" -and $line -notmatch  "DB2" -and $line -notmatch  "RMAN") {$bt="Filefull"} 
              $date =$mn[1].split(" ")[2]  #### get retention ########
              $bdate =$mn[1].split(" ")[1]  #### get backup date ########
              
              $date1str="02/23/2022"   #### start date
              $date2str="03/05/2022"   #### end date
              $date1=[Datetime]::ParseExact($date1str, 'MM/dd/yyyy', $null)   ### convert string to date format
              $date2=[Datetime]::ParseExact($date2str, 'MM/dd/yyyy', $null)   ### convert string to date format
              $newdate=[Datetime]::ParseExact($date, 'MM/dd/yyyy', $null)     ### convert string to date format
              $diff = New-TimeSpan -Start $today -end $newdate
              
              if ( $diff.Days -gt 400 ) {      #### look for 7 year only  ########
                   if ( $arr[12] -ne "Clone_DR") {
                        if ($arr[0] -notin $ht.keys){
                                                 $ht[$arr[0]] = @{}
                                                                                                  
                                                 if ($btype -match "DB2") {  
                                                 $ht[$arr[0]]['Db2size'] = [int64]$arr[1]   ### convert string to integer format
                                                 $ht[$arr[0]]['groups'] = @($backupPlans)  ### adding to array
                                                 $ht[$arr[0]]['type'] = @($bt)              ### adding to array
                                                  }
                                                 if ($btype -match "RMAN") { 
                                                 $ht[$arr[0]]['RMANsize'] =[int64] $arr[1]
                                                 $ht[$arr[0]]['groups'] = @($backupPlans)
                                                 $ht[$arr[0]]['type'] = @($bt)
                                                 } 
                                                 if  ($btype -notmatch "RMAN" -and $btype -notmatch "DB2" ){
                                                 $ht[$arr[0]]['Filesize'] =[int64] $arr[1]
                                                 $ht[$arr[0]]['groups'] = @($backupPlans)
                                                 $ht[$arr[0]]['type'] = @($bt)
                                                 }
                                                 
                                                 } else {
                                                ### If server not in HashTable ###         
                                                if ($btype -match "DB2" -and $arr[1] -gt $ht[$arr[0]]['Db2size'] ) {
                                                $ht[$arr[0]]['Db2size'] += [int64]$arr[1]
                                                ###break $backupplans and loop thru ###
                                                foreach ($gp in $backupPlans){
                                                if ($gp -notin $ht[$arr[0]]['groups']) { 
                                                $ht[$arr[0]]['groups'] += $gp
                                                                             }
                                                                                          }
                                                if ($bt -notin $ht[$arr[0]]['type']){
                                                $ht[$arr[0]]['type'] += $bt}
                                                }                                                                      
                                                if ($btype -match "RMAN" -and $arr[1] -gt $ht[$arr[0]]['RMANsize']) {
                                                
                                                $ht[$arr[0]]['RMANsize'] += [int64]$arr[1]
                                                ###break $backupplans ###
                                                foreach ($gp in $backupPlans){
                                                if ($gp -notin $ht[$arr[0]]['groups'] ) { 
                                                $ht[$arr[0]]['groups'] += $gp
                                                                                  }
                                                          }
                                                  if ($bt -notin $ht[$arr[0]]['type']){
                                                          $ht[$arr[0]]['type'] += $bt}
                                                                                                            } 
                                                if  ($btype -notmatch "RMAN" -and $btype -notmatch "DB2" -and $arr[1] -gt $ht[$arr[0]]['Filesize']){ 
                                                 $ht[$arr[0]]['Filesize'] += [int64]$arr[1]
                                                 ###break $backupplans ###
                                                 foreach ($gp in $backupPlans){
                                                 if ($gp -notin $ht[$arr[0]]['groups']) { 
                                                 $ht[$arr[0]]['groups'] += $gp
                                                                             }
                                                 
                                                                           }
                                                  if ($bt -notin $ht[$arr[0]]['type']){
                                                      $ht[$arr[0]]['type'] += $bt }
                                                 }

                                                    }
                                                    }  ###clone_dr
                                                    }   ###less than 400
                          } ### chcking for networker server
                          } #### looping thru file
write-host "=================================In MB =============================================================================================================================="
write-host "===ServerName==============OverAllsize======DB2size===========RMANsize========FileSize========Groups=============================================BackupType=========="
write-host "====================================================================================================================================================================="

 $ht.GetEnumerator()| ForEach-Object  {
 $total = $_.value.Db2size/1024/1024 + $_.value.RMANsize/1024/1024 + $_.value.Filesize/1024/1024
 "{0}:{1}:{2}:{3}:{4}:{5}:{6}" -f $_.name,$total,$($_.value.Db2size/1024/1024),$($_.value.RMANsize/1024/1024),$($_.value.Filesize/1024/1024),$($_.Value.groups  -join ','),$($_.Value.type  -join ',') | out-file -FilePath $outfile -Append
 "{0,-25}     {1:n2}          {2:n2}            {3:n2}            {4:n2}          {5,-35}   {6,-15}" -f $_.name,$total,$($_.value.Db2size/1024/1024),$($_.value.RMANsize/1024/1024),$($_.value.Filesize/1024/1024),$($_.Value.groups -join ','),$($_.Value.type -join ',')}   

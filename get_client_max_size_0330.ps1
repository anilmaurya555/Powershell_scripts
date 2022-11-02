#########################################manuplation of MMINFO ###############
######mminfo -avot -q "savetime >= '24 February 2022', savetime <= '24 March 2022'" -r client,totalsize,group,policy,workflow,level,sscreate,ssretent,clretent,device,family,nsavetime,action,sumsize,name,location
################################################################################3
#$out=Get-Content C:\anil\scripts\test1.txt
$out=Get-Content C:\anil\networker\mminfo_0328_0407_2022.txt
$ht = @{}
$arr = @()
$today = Get-Date
$outFile = $(Join-Path -Path $PSScriptRoot -ChildPath "Networker_fetb_$(get-date -UFormat '%Y-%m-%d-%H-%M-%S').csv")
"Server Nam:Overall Size in MB:DB2 Size in MB:RMAN Size in MB:File Size in MB:Groups Name:Backup Type:Location" | Out-File -FilePath $outFile
foreach ( $line in $out){                  ###loop1
              $arr=$line -split '\s+' -match '\S'
              if ( $arr[0] -ne "nwsppl300p.corpads.local"){  ###loop2
              $mn=$line -csplit "incr|full|manual" ### split on case sensitive on incr or full or manual
              $md=$mn[1] -split "\s{1,}"   ### split on more than one white space
              #if ($line -match  '.*( backup |Clone_DR ).*') {$btype=$md[9]} elseif ($line -match  '.*( Clone_CT ).*') {$btype=$md[10]} else {$btype=$md[8]}
              $clientHostName,$null,$backupPlans = -split $mn[0] ### split mn[0] in three peice
              if ($line -cmatch  "incr" -and $line -cmatch  "DB2") {$bt="DB2incr"}
              if ($line -cmatch  "manual" -and $line -cmatch  "DB2") {$bt="DB2manual"}
              if ($line -cmatch  "full" -and $line -cmatch  "DB2") {$bt="DB2full"} 
              if ($line -cmatch  "incr" -and $line -cmatch  "RMAN") {$bt="RMANincr"}
              if ($line -cmatch  "manual" -and $line -cmatch  "RMAN") {$bt="RMANmanual"}
              if ($line -cmatch  "full" -and $line -cmatch  "RMAN") {$bt="RMANfull"} 
              if ($line -cmatch  "incr" -and $line -cnotmatch  "DB2" -and $line -cnotmatch  "RMAN") {$bt="Fileincr"}
              if ($line -cmatch  "manual" -and $line -cnotmatch  "DB2" -and $line -cnotmatch  "RMAN") {$bt="Filemanual"}
              if ($line -cmatch  "full" -and $line -cnotmatch  "DB2" -and $line -cnotmatch  "RMAN") {$bt="Filefull"} 
              if ($line -cmatch  "Clone_DR" ) {$lo="Clone_DR"}
              if ($line -cmatch  "Clone_CT" ) {$lo="Clone_CT"}
              if ($line -cmatch  "backup" ) {$lo="Backup"}
              if ($line -match  '.*( backup |Clone_DR ).*') {$btype=$md[9]} elseif ($line -match  '.*( Clone_CT ).*') {$btype=$md[10]} else {$btype=$md[8]}
              
            
              ###########3
             ## add all which don't need decesion
             
             if ($arr[0] -notin $ht.keys){
                                         $ht[$arr[0]] = @{}
                                         $ht[$arr[0]]['groups'] = @($backupPlans)
                                         $ht[$arr[0]]['type'] = @($bt) 
                                         $ht[$arr[0]]['Location'] = @($lo)
                                         } 
             
                   if ( $line -cnotmatch  "manual" -and $line -cnotmatch  "Clone_DR" -and $line -cnotmatch  "Clone_CT") { ###loop3
                                             
                                                 if ($btype -match "DB2") {  
                                                 
                                                 $ht[$arr[0]]['Db2size'] += [int64]$arr[1]
                                                 if ($bt -notin $ht[$arr[0]]['type']){
                                                          $ht[$arr[0]]['type'] += $bt} 
                                                 foreach ($gp in $backupPlans){
                                                    if ($gp -notin $ht[$arr[0]]['groups']) { 
                                                         $ht[$arr[0]]['groups'] += $gp
                                                                              }
                                                                                }
                                                     if ($lo -notin $ht[$arr[0]]['Location'] ){
                                                      $ht[$arr[0]]['Location'] += $lo }  
                                                                           }
                                                
                                                 if ($btype -match "RMAN") { 
                                                 
                                                 $ht[$arr[0]]['RMANsize'] +=[int64] $arr[1]
                                                 if ($bt -notin $ht[$arr[0]]['type']){
                                                          $ht[$arr[0]]['type'] += $bt}
                                                 foreach ($gp in $backupPlans){
                                                    if ($gp -notin $ht[$arr[0]]['groups']) { 
                                                         $ht[$arr[0]]['groups'] += $gp
                                                                              }
                                                                                }
                                                    if ($lo -notin $ht[$arr[0]]['Location'] ){
                                                      $ht[$arr[0]]['Location'] += $lo }
                                                                            }
                                                 
                                                 if  ($btype -cnotmatch "RMAN" -and $btype -cnotmatch "DB2" ){
                                                 
                                                 $ht[$arr[0]]['Filesize'] +=[int64] $arr[1]
                                                 if ($bt -notin $ht[$arr[0]]['type']){
                                                          $ht[$arr[0]]['type'] += $bt}
                                                 foreach ($gp in $backupPlans){
                                                    if ($gp -notin $ht[$arr[0]]['groups']) { 
                                                         $ht[$arr[0]]['groups'] += $gp
                                                                              }
                                                                                }
                                                    if ($lo -notin $ht[$arr[0]]['Location'] ){
                                                      $ht[$arr[0]]['Location'] += $lo }
                                                                                              }  
                                                   
                          } else {
                                  if ($btype -cmatch "DB2" -and $line -cmatch  "manual") {
                                                     $ht[$arr[0]]['RMANsize'] +=[int64] $arr[1]  #### DB2 runs manual backup by DBA
                                                           if ($lo -notin $ht[$arr[0]]['Location'] ){
                                                      $ht[$arr[0]]['Location'] += $lo }
                                                      if ($bt -notin $ht[$arr[0]]['type']){
                                                          $ht[$arr[0]]['type'] += $bt}
                                                            }
                                  if ($btype -cmatch "RMAN" -and $line -cmatch  "manual") {
                                                            $ht[$arr[0]]['RMANsize'] +=[int64] $arr[1]  #### RMAN runs only manual backup by DBA
                                                            if ($lo -notin $ht[$arr[0]]['Location'] ){
                                                      $ht[$arr[0]]['Location'] += $lo }
                                                      if ($bt -notin $ht[$arr[0]]['type']){
                                                          $ht[$arr[0]]['type'] += $bt}
                                                            }
                                   if  ($btype -cnotmatch "RMAN" -and $btype -cnotmatch "DB2" ){
                                                            if ($lo -notin $ht[$arr[0]]['Location'] ){
                                                      $ht[$arr[0]]['Location'] += $lo }
                                                      if ($bt -notin $ht[$arr[0]]['type']){
                                                          $ht[$arr[0]]['type'] += $bt}
                                                            }

                                 }  ### loop3
                          
                          
                          } #### loop2
                          } ###loop1
write-host "=================================In MB ======================================================================================================================================"
write-host "===ServerName==============OverAllsize======DB2size===========RMANsize========FileSize========Groups=============================================BackupType==========Location"
write-host "============================================================================================================================================================================="

 $ht.GetEnumerator()| ForEach-Object  {
 $total = $_.value.Db2size/1024/1024 + $_.value.RMANsize/1024/1024 + $_.value.Filesize/1024/1024
 "{0}:{1}:{2}:{3}:{4}:{5}:{6}:{7}" -f $_.name,$total,$($_.value.Db2size/1024/1024),$($_.value.RMANsize/1024/1024),$($_.value.Filesize/1024/1024),$($_.Value.groups  -join ','),$($_.Value.type  -join ','),$($_.Value.Location  -join ',') | out-file -FilePath $outfile -Append
 "{0,-25}     {1:n2}          {2:n2}            {3:n2}            {4:n2}          {5,-35}   {6,-15}   {7,-10}" -f $_.name,$total,$($_.value.Db2size/1024/1024),$($_.value.RMANsize/1024/1024),$($_.value.Filesize/1024/1024),$($_.Value.groups -join ','),$($_.Value.type -join ','),$($_.Value.Location -join ',')  
 } 
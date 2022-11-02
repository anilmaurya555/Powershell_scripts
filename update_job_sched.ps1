[cmdletbinding()]
param (
      [parameter ( mandatory = $True)][string]$vip,
      [Parameter()][int32]$hour ,
      [Parameter()][int32]$athr ,
      [Parameter()][int32]$starthr ,
      [Parameter()][int32]$endhr ,
      [parameter()][switch] $update
      )
. .\cohesity-api.ps1
apiauth -vip $vip -username amaurya -domain corpads.local
#$jobname = get-content c:\anil\scripts\jobs.txt 
$jobs = @() 

                          $alljobs = api get protectionJobs
                          
                          

foreach ( $job in $alljobs ) {
                             $jobid= $job.id
                             $jobname = $job.name
                             $jobtime = $job.starttime.hour
                             if($athr -eq $jobtime  ) {
                                         "$jobname, $jobtime"
                        #  $string="Hcohesity03_ALP00273_Win_one_year_0900PM"
                        #  $string -replace '(.+?)_\d.+','$1'
                        #  Hcohesity03_ALP00273_Win_one_year
                                               $jobname = $job.name -replace "_\d{1,2}",""
                                               $job.starttime.hour = $hour
                                               $time = "PM"
                                               $job.name = $jobname +"_"+$time 

                                               if ($update){

                                               $null = api put protectionJobs/$jobid $job
                                                     "$job.name updated"
                                                           }

                                      }
                                    elseif ($jobtime -gt $starthr -and $jobtime -lt $endhr){
                                               "$jobname, $jobtime"
                                               $jobname = $job.name -replace "_\d{1,2}",""
                                               $job.starttime.hour = $hour
                                               $time = "PM"
                                               $job.name = $jobname +"_"+$time 

                                               if ($update){

                                               $null = api put protectionJobs/$jobid $job
                                                     "$($job.name) updated"
                                                           }
                                               
                                                                               }

                             } 



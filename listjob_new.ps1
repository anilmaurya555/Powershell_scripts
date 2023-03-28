[cmdletbinding()]
param (
      [parameter ( mandatory = $True)][string]$vip,
      [parameter ()][array]$prefix = 'All',
      [parameter ()] [switch] $count,
      [parameter ()] [switch] $detailjob,
      [parameter ()] [string] $bypolicy,
      [parameter ()] [switch] $listAlljobnames
      )
. .\cohesity-api.ps1
apiauth -vip $vip -username aym15-sa -domain ent.ad.ntrs.com
$jobs = (api get protectionJobs | Where-Object {$_.isdeleted -ne $True -and $_.isactive -ne $false -and $_.isPaused -eq $false})

$policies = api get protectionPolicies
if ($listAlljobnames){

                    forEach ($job in $jobs ){
                                          $job.name
                                          }

                  }elseif ($bypolicy){
                  "Job Name                          Storage cinsumed in GB"
                  "========================================================"
                  
                  $policyid = ($policies|where {$_.name -eq $bypolicy}).id
                  
                  foreach ($job in $jobs){
                        
                        if ($job.policyID -eq $policyid){
                        $stats = api get "stats/consumers?consumerType=kProtectionRuns&consumerIdList=$($job.id)"
                        $consumedBytes = $stats.statsList[0].stats.storageConsumedBytes
                         $consumption = [math]::Round($consumedBytes / (1024 * 1024 * 1024), 2)
                        "{0,-40}  {1,10}" -F $job.name,$consumption

                                                       }
                                         }             
                  
                  
                  
                  }elseif($detailjob){
                  "Job Nmae                                                       Vcenter Nmae                     Policy Name               start Time"
                  "===================================================================================================================================="
                  $parentsources = api get protectionSources
                  #$parentsources |ConvertTo-Json -Depth 25
                  forEach ($job in $jobs ){
                    $jobname= $job.name
                    $starttime = "$($job.startTime.hour):$($job.startTime.minute)"
                     
                    foreach ($ptsource in $parentsources){

                    if ($ptsource.protectionSource.id -eq $job.parentSourceId){
                                             $vcentername  = $ptsource.protectionSource.name
                                                                } 
                                                       }
                   foreach ($policy in $policies){
                                                                                         
                              if ($policy.id -eq $job.policyId ){
                                     $policyname = $policy.name.Tolower()
                                     }
                                  }
                    "{0,-60}  {1,-30}  {2,-35}  {3,-20}" -f $jobname,$vcentername,$policyname,$starttime
                                  
                                  }   ###each job
                    

                  #######

                        }else{

                    forEach ($job in $jobs ){
                            $jobname= $job.name
                            #$jobname
                             if ($jobname.tolower() -like "$prefix*" -or $jobname.tolower() -like "*$prefix*" -or $jobname.tolower() -like "*$prefix" -or $prefix -eq 'ALL') {
                              $clients = @()
                                 $newcount = 0
                                     $report = api get reports/protectionSourcesJobsSummary?jobIds=$($job.id)
                                  foreach($summary in $report.protectionSourcesJobsSummary){
                                $clients += $summary.protectionSource.name                                           
                                           $newcount += 1 
                                                } 
                                                   if ($count) {
                                                             "Total CLIENT ($newcount) in Job ($jobname)  ($($job.startTime.hour):$($job.startTime.minute))"
                                                             #$jobname
                                                             } else {
                                                             "`nJob name"
                                                             $jobname
                                                             "`nClinets list"
                                                             $clients
                                                                  }                                   
                                                }
                                         }
                         }
                         
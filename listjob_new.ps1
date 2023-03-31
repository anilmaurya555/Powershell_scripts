[cmdletbinding()]
param (
      [parameter ( mandatory = $True)][string]$vip,
      [parameter ()][array]$prefix ,
      [parameter ()] [switch] $count,
      [Parameter ()][array]$jobNames, #jobs for which user wants to list/cancel replications
      [Parameter ()][string]$joblist = '',
      [parameter ()] [switch] $detailjob,
      [parameter ()] [string] $bypolicy,
      [parameter ()] [switch] $listAlljobnames
      )
. .\cohesity-api.ps1
$outFile = $(Join-Path -Path $PSScriptRoot -ChildPath "out.txt")

function gatherList($Param=$null, $FilePath=$null, $Required=$True, $Name='items'){
    $items = @()
    if($Param){
        $Param | ForEach-Object {$items += $_}
    }
    if($FilePath){
        if(Test-Path -Path $FilePath -PathType Leaf){
            Get-Content $FilePath | ForEach-Object {$items += [string]$_}
        }else{
            Write-Host "Text file $FilePath not found!" -ForegroundColor Yellow
            exit
        }
    }
    if($Required -eq $True -and $items.Count -eq 0){
        Write-Host "No $Name specified" -ForegroundColor Yellow
        exit
    }
    return ($items | Sort-Object -Unique)
}

$alljobNames = @(gatherList -Param $jobNames -FilePath $jobList -Name 'jobs' -Required $false)

$jobs = @()
apiauth -vip $vip -username aym15-sa -domain ent.ad.ntrs.com
$rawjobs = (api get protectionJobs | Where-Object {$_.isdeleted -ne $True -and $_.isactive -ne $false -and $_.isPaused -eq $false})
if ($jobNames -or $jobList){
    foreach ($job in $rawjobs){
            if ($job.name -in $alljobNames){
                         $jobs += $job
                                        }

                                  }
     

                           }elseif ($prefix){
                         foreach ($job in $rawjobs){
                           if ($job.name.tolower() -like "$prefix*" -or $job.name.tolower() -like "*$prefix*" -or $job.name.tolower() -like "*$prefix"){
                                         $jobs += $job
                                                    }                                                  

                                                  }
                                            }else {

                                            $jobs = $rawjobs
                                            }

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
                  "Job Nmae                                                       Vcenter Nmae                     Policy Name                 Client Count       start Time"
                  "========================================================================================================================================================="
                  $parentsources = api get protectionSources
                  #$parentsources |ConvertTo-Json -Depth 25
                  forEach ($job in $jobs ){
                    $jobname= $job.name
                    $starttime = "$($job.startTime.hour):$($job.startTime.minute)"
                                  #$job|ConvertTo-Json -Depth 10 |Out-File -FilePath $outFile
                                                       
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
                    "{0,-60}  {1,-30}  {2,-35}  {3,-10}  {4,-20}" -f $jobname,$vcentername,$policyname,($job.sourceIds).count,$starttime
                                  
                                  }   ###each job
                    

                  #######

                        }else{

                    forEach ($job in $jobs ){
                            $jobname= $job.name
                            #$jobname
                             
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
                         

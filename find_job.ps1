#connect-CohesityCluster -Server sbch-dp01br.selective.com

$jobs = Get-CohesityProtectionJob
Get-CohesityProtectionSourceObject |set-content "C:\anil\powershell\input555.txt"
$sources = Get-CohesityProtectionSourceObject
#$sources = get-content "c:\anil\powershell\servers.txt"


             foreach ($source in @($sources | Where-Object { $_.NAME -eq 'DB294' -and $_.Environment -eq 'kPhysical'})){
                              
                              $environment = $source.environment

                                $name = $source.name

                             $job = $jobs | Where-Object { $_.sourceIds -eq $source.id }

                 if($job){

                         $jobName = $job.Name

                         }else{

                              $jobName = '<not protected>'

                                 }

                                 "($environment) $name`t$jobName" 

                               }


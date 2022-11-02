[cmdletbinding()]
param (
      [parameter ( mandatory = $True)][string]$vip,
      [parameter ()][array]$prefix= 'ALL',
      [parameter ()] [switch] $count,
      [parameter ()] [switch] $listjobnames
      )
. .\cohesity-api.ps1
apiauth -vip $vip -username amaurya -domain corpads.local
$jobs = (api get protectionJobs | Where-Object {$_.isdeleted -ne $True -and $_.isactive -ne $false})

if ($listjobnames){

                    forEach ($job in $jobs ){
                                          $job.name
                                          }

                  }else{

                    forEach ($job in $jobs ){
                            $jobname= $job.name
                            #$jobname
                             if ($jobname.tolower() -like "*$prefix*" -or $prefix -eq 'ALL') {
                              $clients = @()
                                 $newcount = 0
                                     $report = api get reports/protectionSourcesJobsSummary?jobIds=$($job.id)
                                  foreach($summary in $report.protectionSourcesJobsSummary){
                                $clients += $summary.protectionSource.name                                           
                                           $newcount += 1 
                                                } 
                                                   if ($count) {
                                                             "Total CLIENT ($newcount) in Job ($jobname)"
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
                         
. ./cohesity-api.ps1
apiauth -vip cohesity651 -user admin



$jobs = api get protectionJobs?isDeleted=false


foreach ($job in $jobs){
                       $jobId = $job.id
                       $runs = api get "protectionRuns?jobId=$($job.id)&excludeTasks=true&numRuns=9999"
                            foreach($run in $runs){
                                      
                                      
                                               
                                                                                         #$run
                                                                                          $run.backupRun.SourceBackupStatus | foreach-object {
                                                                                          "`t$($_.Status)`t$($_.Source.Name)"
                                                                                                           }
                                                                                       
                                                   }
                         }
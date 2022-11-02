
. .\cohesity-api.ps1
apiauth -vip sbch-dp01br.selective.com -domain sigi.us.selective.com -username maurya1
$runs = api get protectionRuns

$finishedStates = @('kCanceled','kSuccess', 'kFailure')
foreach ($run in $runs){

                     $jobName = $run.jobName

                     foreach ($copyRun in $run.copyRun){

                                     if ($copyRun.target.type -eq 'kRemote'){

                                                                     if ($copyRun.status -notin $finishedStates){

                                                                              $targetType = $copyRun.target.type.substring(1)

                                                                              $status = $copyRun.status.substring(1)

                                                                              "{0,-30} {1,-15} {2}" -f ($jobName,$targetType, $status)

                                                                                                           }

                                                                            }

                                                        }

                            }



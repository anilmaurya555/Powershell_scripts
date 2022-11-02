### report job run statistics

### usage: ./jobRunStats.ps1 -vip mycluster -username admin [ -domain local ]

### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][string]$domain = 'local',
    [Parameter(Mandatory = $True)][string]$jobName, # job to run
    [Parameter()][switch]$last7Days,
    [Parameter()][switch]$lastDay
)

### source the cohesity-api helper code
. ./cohesity-api

### authenticate
apiauth -vip $vip -username $username -domain $domain


$MB = 1024*1024

$dateString = (get-date).ToString().Replace(' ','_').Replace('/','-').Replace(':','-')
$outfileName = "RunStats-$dateString.csv"
"JobName,Job start Time,Status,RunType,Duration in Min, ReadGBytes, writeGBytes" | Out-File -FilePath $outfileName

$jobs = api get protectionJobs?isDeleted=false

"{0,-20}            {1,-10}   {2,-10} {3,10} {4,15} {5,15}" -f "Job start Time", "Status", "RunType", "Duration in Min", "ReadGBytes", "writeGBytes"
                "======================================================================================================"

foreach ($job in $jobs){     #  starts jobs loop
    
                 if ( $jobname -eq $job.name){
                   $jobId = $job.id
                    $runs = api get "protectionRuns?jobId=$($job.id)&excludeTasks=true&numRuns=9999"
                                             }
                       }

    foreach ($run in $runs){
        $nowTime = dateToUsecs (get-date)
        $startTime = $run.copyRun[0].runStartTimeUsecs
        if($lastDay){
             if (($nowTime - $startTime -le 86400000000)-and ($run.backupRun.runType.substring(1) -eq "Regular")){   #  starts last day
            $runId = $run.backupRun.jobRunId
            $endTime = $run.backupRun.stats.endTimeUsecs
            $duration = [math]::Round(($endTime - $startTime)/1000000,0)
            $runType = $run.backupRun.runType.substring(1)
            $readMBytes = [math]::Round($run.backupRun.stats.totalBytesReadFromSource / $MB, 2)
            $writeMBytes = [math]::Round($run.backupRun.stats.totalPhysicalBackupSizeBytes / $MB, 2)
            $logicalMBytes = [math]::Round($run.backupRun.stats.totalLogicalBackupSizeBytes / $MB, 2)
            $status = $run.backupRun.status.substring(1)
            
            if(! $failedOnly -or ($failedOnly -and $status -ne "Success")){
                
                "{0,-25}        {1,-10}  {2,-10} {3,10} {4,15} {5,15}" -f (usecsToDate $startTime), $status, $runType, $([math]::Round($duration/60,2)), $([math]::Round($readMBytes/1024,3)), $([math]::Round($writeMBytes/1024,3))
                "$jobName,$(usecsToDate $startTime),$status, $runType, $([math]::Round($duration/60,2)), $([math]::Round($readMBytes/1024,3)), $([math]::Round($writeMBytes/1024,3))" | Out-File -FilePath $outfileName -Append
                                                                          }
                                                                                                         }
                } elseif ($last7Days) {    #  end last day 
                                                    
                               if (($nowTime - $startTime -le (7 * 86400000000)) -and ($run.backupRun.runType.substring(1) -eq "Regular")){                                
                                $runId = $run.backupRun.jobRunId
                                $endTime = $run.backupRun.stats.endTimeUsecs
                                $duration = [math]::Round(($endTime - $startTime)/1000000,0)
                                $runType = $run.backupRun.runType.substring(1)
                                $readMBytes = [math]::Round($run.backupRun.stats.totalBytesReadFromSource / $MB, 2)
                                $writeMBytes = [math]::Round($run.backupRun.stats.totalPhysicalBackupSizeBytes / $MB, 2)
                                $logicalMBytes = [math]::Round($run.backupRun.stats.totalLogicalBackupSizeBytes / $MB, 2)
                                $status = $run.backupRun.status.substring(1)
            
                                if(! $failedOnly -or ($failedOnly -and $status -ne "Success")){
                
                                    "{0,-25}        {1,-10}  {2,-10} {3,10} {4,15} {5,15}" -f (usecsToDate $startTime), $status, $runType, $([math]::Round($duration/60,2)), $([math]::Round($readMBytes/1024,3)), $([math]::Round($writeMBytes/1024,3))
                                    "$jobName,$(usecsToDate $startTime),$status, $runType, $([math]::Round($duration/60,2)), $([math]::Round($readMBytes/1024,3)), $([math]::Round($writeMBytes/1024,3))" | Out-File -FilePath $outfileName -Append
                                                                                            }
                                 }
                                                             

                } else {
                                if ($run.backupRun.runType.substring(1) -eq "Regular"){
                                $runId = $run.backupRun.jobRunId
                                $endTime = $run.backupRun.stats.endTimeUsecs
                                $duration = [math]::Round(($endTime - $startTime)/1000000,0)
                                $runType = $run.backupRun.runType.substring(1)
                                $readMBytes = [math]::Round($run.backupRun.stats.totalBytesReadFromSource / $MB, 2)
                                $writeMBytes = [math]::Round($run.backupRun.stats.totalPhysicalBackupSizeBytes / $MB, 2)
                                $logicalMBytes = [math]::Round($run.backupRun.stats.totalLogicalBackupSizeBytes / $MB, 2)
                                $status = $run.backupRun.status.substring(1)
            
                                if(! $failedOnly -or ($failedOnly -and $status -ne "Success")){
                
                                    "{0,-25}        {1,-10}  {2,-10} {3,10} {4,15} {5,15}" -f (usecsToDate $startTime), $status, $runType, $([math]::Round($duration/60,2)), $([math]::Round($readMBytes/1024,3)), $([math]::Round($writeMBytes/1024,3))
                                    "$jobName,$(usecsToDate $startTime),$status, $runType, $([math]::Round($duration/60,2)), $([math]::Round($readMBytes/1024,3)), $([math]::Round($writeMBytes/1024,3))" | Out-File -FilePath $outfileName -Append
                                                                                            }
                                                                                          }

                        }
    }

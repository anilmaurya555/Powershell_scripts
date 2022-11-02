# usage:
# ./objectReport.ps1 -vip mycluster `
#                  -username myusername `
#                  -domain mydomain.net `
#                  -prefix demo, test `
#                  -includeDatabases `
#                  -sendTo myuser@mydomain.net, anotheruser@mydomain.net `
#                  -smtpServer 192.168.1.95 `
#                  -sendFrom backupreport@mydomain.net

### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip, #the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username, #username (local or AD)
    [Parameter()][string]$domain = 'local' #local or AD domain
    
)

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

# authenticate
apiauth -vip $vip -username $username -domain $domain
# get cluster info
$cluster = api get cluster

$outFile = $(Join-Path -Path $PSScriptRoot -ChildPath "DailyStatus_Report-$($cluster.name).csv")
"Object Type,Object Name,Database,Registered Source,Job Name,Available Snapshots,Latest Status,Schedule Type,Last Start Time,Last End Time,Logical MB,Read MB,Written MB,Change %,Failure Count,Error Message" | Out-File -FilePath $outFile



# environment types
$envType = @('kUnknown', 'kVMware', 'kHyperV', 'kSQL', 'kView', 'kRemote Adapter', 
             'kPhysical', 'kPure', 'kAzure', 'kNetapp', 'kAgent', 'kGenericNas', 
             'kAcropolis', 'kPhysical Files', 'kIsilon', 'kKVM', 'kAWS', 'kExchange', 
             'kHyperVVSS', 'kOracle', 'kGCP', 'kFlashBlade', 'kAWSNative', 'kVCD',
             'kO365', 'kO365 Outlook', 'kHyperFlex', 'kGCP Native', 'kAzure Native',
             'kAD', 'kAWS Snapshot Manager', 'kFuture', 'kFuture', 'kFuture')

$runType = @('kRegular', 'kFull', 'kLog', 'kSystem')

$objectStatus = @{}

function latestStatus($objectName,
                      $registeredSource,
                      $logicalSize = 0,
                      $dataWritten = 0,
                      $dataRead = 0){

    $thisStatus = @{'registeredSource' = $registeredSource;
                    'logicalSize' = $logicalSize;
                    'dataWritten' = $dataWritten;
                    'dataRead' = $dataRead}

    
    
    if($objectName -notin $objectStatus.Keys -or $startTimeUsecs -gt $objectStatus[$objectName].lastRunUsecs){
        $objectStatus[$objectName] = $thisStatus
    }
}



# gather job info
write-host "Gathering Job Stats..."

$jobSummary = api get '/backupjobssummary?_includeTenantInfo=true&allUnderHierarchy=true&includeJobsWithoutRun=false&isActive=true&isDeleted=false&numRuns=1000&onlyReturnBasicSummary=true&onlyReturnJobDescription=false'

foreach($job in $jobSummary | Sort-Object -Property { $_.backupJobSummary.jobDescription.name }){
    $registeredSource = $job.backupJobSummary.jobDescription.parentSource.displayName
    if($job.backupJobSummary.jobDescription.isPaused -eq $True){
        $isPaused = $True
    }else{
        $isPaused = $false
    }
    $jobName = $job.backupJobSummary.jobDescription.name
    
    
    }
    
        write-host "  $jobName"
        $startTimeUsecs = $job.backupJobSummary.lastProtectionRun.backupRun.base.startTimeUsecs
        $endTimeUsecs = $job.backupJobSummary.lastProtectionRun.backupRun.base.endTimeUsecs
        $jobId = $job.backupJobSummary.lastProtectionRun.backupRun.base.jobId
        if($jobId -and $startTimeUsecs){
            $lastrun = api get "/backupjobruns?allUnderHierarchy=true&exactMatchStartTimeUsecs=$startTimeUsecs&id=$jobId&onlyReturnDataMigrationJobs=false"
            $scheduleType = $runType[$lastrun.backupJobRuns.protectionRuns[0].backupRun.base.backupType]
            if($lastrun.backupJobRuns.protectionRuns[0].backupRun.PSObject.Properties['activeAttempt']){
                $endTimeUsecs = 0
                $message = ''
                $attempt = $lastrun.backupJobRuns.protectionRuns[0].backupRun.activeAttempt.base
                $status = $attempt.publicStatus
                $jobType = $attempt.type
                
            }
            foreach($task in $lastrun.backupJobRuns.protectionRuns[0].backupRun.latestFinishedTasks){
        
                $status = $task.base.publicStatus
                $jobType = $task.base.type
                $entity = $task.base.sources[0].source.displayName
                $dataWritten = $task.base.totalPhysicalBackupSizeBytes
                $dataRead = $task.base.totalBytesReadFromSource
                $logicalSize = $task.base.totalLogicalBackupSizeBytes
                if($status -eq 'kFailure'){
                    $message = $task.base.error.errorMsg
                }elseif ($status -eq 'kWarning') {
                    $message = $task.base.warnings[0].errorMsg
                }else{
                    $message = ''
                }
                if($message.Length -gt 100){
                    $message = $message.Substring(0,99)
                }
        
                if($task.PSObject.Properties['appEntityStateVec']){
                    foreach($app in $task.appEntityStateVec){
                        $appEntity = $app.appentity.displayName
                        $appStatus = $app.publicStatus
                        if($null -eq $appStatus){
                            $appStatus = $status
                        }
                        $objectName = "$entity/$appEntity"
                        $logicalSize = $app.totalLogicalBytes
                        $dataRead = $app.totalBytesReadFromSource
                        $dataWritten = $app.totalPhysicalBackupSizeBytes
                        if($appStatus -eq 'kFailure'){
                            $message = $task.base.error.errorMsg
                        }elseif ($appStatus -eq 'kWarning') {
                            $message = $task.base.warnings[0].errorMsg
                        }else{
                            $message = ''
                        }
                        if($message.Length -gt 100){
                            $message = $message.Substring(0,99)
                        }
                        latestStatus -objectName $objectName `
                                     -registeredSource $registeredSource `
                                     -logicalSize $logicalSize `
                                     -dataWritten $dataWritten `
                                     -dataRead $dataRead
                    }
                }else{
                    $objectName = $entity
                    latestStatus -objectName $objectName `
                                 -registeredSource $registeredSource `
                                 -logicalSize $logicalSize `
                                 -dataWritten $dataWritten `
                                 -dataRead $dataRead
                }
            }
        }
    

# populate html rows
foreach ($entity in $objectStatus.Keys | Sort-Object){
    
    $logicalSize = $objectStatus[$entity].logicalSize
    $dataWritten = $objectStatus[$entity].dataWritten
    $dataRead = $objectStatus[$entity].dataRead
    if($dataRead -gt 0){
        $displayRead = [math]::Round($dataRead/(1024*1024),3)
    }else{
        $displayRead = 0
    }
    if($logicalSize -gt 0){
        $changeRate = $dataWritten / $logicalSize
        $changeRatePct = [math]::Round(100 * $changeRate, 1)
        $displaySize = [math]::Round($logicalSize/(1024*1024),3)
    }else{
        $changeRatePct = 0
        $displaySize = 0
    }
    if($dataWritten -gt 0){
        $displayWritten = [math]::Round($dataWritten/(1024*1024),3) 
    }else{
        $displayWritten = 0
    }
   
    
    "{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}" -f $environment,$objectName,$app,$registeredSource,$jobName,$numSnapshots,$status,$scheduleType,$lastRunStartTime,$endTime,$displaySize,$displayRead,$displayWritten,$changeRatePct,$numErrors,$lastRunErrorMsg | out-file -FilePath $outfile -Append


}


$outFilePath = join-path -Path $PSScriptRoot -ChildPath 'objectreport.html'

.$outFilePath
$attachfile = @("$outfile")
# send email report
#write-host "sending report to $([string]::Join(", ", $sendTo))"
#foreach($toaddr in $sendTo){
   # Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "$prefixTitle backupSummaryReport ($($cluster.name))" -BodyAsHtml $html -WarningAction SilentlyContinue -Attachments $attachfile
#}
#$html | out-file "$($cluster.name)-objectreport.html"
# usage:
# ./dailyfailurereport.ps1 -vip mycluster `
#                  -username myusername `
#                  -domain mydomain.net `
#                  -prefix demo, test `
#                  -includeDatabases `
#                  -sendTo myuser@mydomain.net, anotheruser@mydomain.net `
#                  -smtpServer 192.168.1.95 `
#                  -sendFrom backupreport@mydomain.net
# weekly summary report

### process commandline arguments
[CmdletBinding()]
param (
    #[Parameter(Mandatory = $True)][string]$vip, #the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username, #username (local or AD)
    #[Parameter()][string]$domain = 'local', #local or AD domain
    [Parameter()][array]$prefix = 'ALL', #report jobs with 'prefix' only
    [Parameter()][string]$smtpServer, #outbound smtp server '192.168.1.95'
    [Parameter()][switch]$includeDatabases , #switch to include individual databases or not
    [Parameter()][string]$smtpPort = 25, #outbound smtp port
    [Parameter()][switch]$weekly, #weekly numbers
    [Parameter()][array]$sendTo, #send to address
   [Parameter()][string]$sendFrom #send from address
)

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

####HTML code ###########
$title = "Cohesity Weekly Clients Summary Report as of "
$date = (get-date).ToString()
$html = '<html>
<head>
    <style>
        p {
            color: #555555;
            font-family:Arial, Helvetica, sans-serif;
        }
        span {
            color: #555555;
            font-family:Arial, Helvetica, sans-serif;
        }
        
        table {
            font-family: Arial, Helvetica, sans-serif;
            border: 3px solid maroon;
            font-size: 0.75em;
            border-collapse: collapse;
             width:25%;
		 margin:0 auto;
            
        }
     
        }
        tr {
            border: 1px solid #F1F1F1;
        }
        td {
            border:2px solid blue;
		   padding:10px;
            text-align: left;
            background-color: #EAFAF1;
            
        }
        th {
            border:2px solid blue;
		   padding:10px;
            text-align: left;
            font-size:12pt;
            background-color: #FFC300;
            
        }
        
        tr:nth-child(even) {
            background-color: #FADBD8;
        }
    </style>
</head>
<body>
    
    <div style="margin:15px;">
        <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAARgAAAAoCAMAAAASXRWnAAAC8VBMVE
        WXyTz///+XyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
        yXyTyXyTyXyTyXyTwJ0VJ2AAAA+nRSTlMAAAECAwQFBgcICQoLDA0ODxARExQVFhcYGRobHB0eHy
        EiIyQlJicoKSorLC0uLzAxMjM0NTY3ODk6Ozw9Pj9AQUNERUZHSElKS0xNTk9QUVJTVFVWV1hZWl
        tcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9foCBgoOEhYaHiImKi4yNjo+QkZKTlJ
        WWl5iZmpucnZ6foKGio6SlpqeoqaqrrK2ur7CxsrO0tba3uLm6u7y9vr/AwcLDxMXGx8jJysvMzc
        7Q0dLT1NXW19jZ2tvc3d7f4OHi4+Xm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+drbbjAAACOZJRE
        FUaIHtWmlcVUUUv6alIgpiEGiZZIpiKu2i4obhUgipmGuihuZWiYmkRBu4JJVappaG5VJRUWrllq
        ZWivtWVuIWllHwShRI51PvnjP33pk7M1d579Gn/j8+zDnnf2b5v3tnu2g1/ocUmvuPRasx83cVu1
        zFB5endtWUCHgoM/+0y1V64sOZcXVlhMDpWXdLM+PmPnmdZTVJeLCPiL6Jd9jT6nfo2y+hH4vE/h
        Fcj6bP6uhcqxvxfYzOdsxOb6gYm39qdrRmE6bBxB2EQWHOXfLBvVvMsIqWdBEYzYvcgWRJ6nS3f5
        +/YSWXEQVeYJPqpXx5XkaaalFuOu22h2E5UVkrIadaAyXFXTwbKh1cw0J3bCgvzFO/CRWtuk3IjP
        lKYK23C7ga3IFCblPwp1HrNvUAyH1W0tRzKlIbk/OmbpbX04uNHGp1/9j6MxMMxUNSYXbqoTJWmF
        t3yCqqHGVLzJK2l8qTtoOzldBqD/C/Ra3hDgOYZKTU2awmpZgVbwG7udWGEvovHYXFHIkuYzHECN
        Pzb0VNy9g8/60KVh5X/QbwtRCajQH//GsQ5k7KCTzqQGprVrwW7HC9GOKQQMhpP30UpWiIM0XYZQ
        gcsYR50Mo9vj73vS9+sOy1Vl6A5S7auXJ53v4Lpr2Trf9LcN0utNsZ/K9Ra4iy++XGE+h3zGGQaV
        bFn+n2lWZQ7q/6id04iW/fI2idFTp4CAOdTWHuNFWZQCf7luMOGr4e9jxCXu1WBxw3Ja03XJs8FG
        ZFdBcbusY2NRKM2k9mD32oXwKLxIGRTMWsMFpon14PAGKTynX/9z17ot27Z23KxyeMLLT1bw6hHT
        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
        8LK0YAAAAASUVORK5CYII=" style="width:180px">
        <p style="margin-top: 15px; margin-bottom: 15px;">
            <span style="font-size:1.3em;">'

$html += $title
$html += '</span>
<span style="font-size:1em; text-align: right; padding-top: 300px; padding-right: 100px; float: center;">'
$html += $date

$html += '</table>
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:0.5em;color: #0000FF"> Below report also available on NAS share : \\hcohesity05\cohesity_reports </span></span></p>
<p style="margin-top: 15px; margin-bottom: 15px; text-align: center;"><span style="font-size:0.5em;color: #0000FF"">Contact Anil Maurya for any question/comments on this report.</span></span></p>
</html>'

$html += '</span>
</p>
<table>
<tr><td colspan=9 style="background-color: #93C572; font-size: 28px;font-weight: bold;" >Last Week Cohesity Backup stats.</td></tr>
<tr>
    <td style="background-color:#FFC300; font-size:12pt;">Cluster Name</td>
    <td style="background-color:#FFC300; font-size:12pt;">Total Clients</td>
    <td style="background-color:#FFC300; font-size:12pt;">Failed clients</td>
    <td style="background-color:#FFC300; font-size:12pt;">Running Clients</td>
    <td style="background-color:#FFC300; font-size:12pt;">Canceled Clients</td>
    <td style="background-color:#FFC300; font-size:12pt;">Success Clients</td>
    <td style="background-color:#FFC300; font-size:12pt;">Completed with Exception</td>
    <td style="background-color:#FFC300; font-size:12pt;">Data Written in TB</td>
    <td style="background-color:#FFC300; font-size:12pt;">Overall success</td>

</tr>'

##################33
##grand total initaialization ##
$GtotalObjects = 0
$GSuccessnum = 0
$GWarningnum = 0
$GRunningnum = 0
$GCancelednum = 0
$GtotalFailedObjects = 0
$GpercentFailed = 0
$Gdatawritten = 0
$Gnrecovery = 0
$GNrecoveryf = 0
$GNrecoverys = 0
$Gorecoverys = 0

################

# environment types
$envType = @('kUnknown', 'kVMware', 'kHyperV', 'kSQL', 'kView', 'kRemote Adapter', 
             'kPhysical', 'kPure', 'kAzure', 'kNetapp', 'kAgent', 'kGenericNas', 
             'kAcropolis', 'kPhysical Files', 'kIsilon', 'kKVM', 'kAWS', 'kExchange', 
             'kHyperVVSS', 'kOracle', 'kGCP', 'kFlashBlade', 'kAWSNative', 'kVCD',
             'kO365', 'kO365 Outlook', 'kHyperFlex', 'kGCP Native', 'kAzure Native',
             'kAD', 'kAWS Snapshot Manager', 'kFuture', 'kFuture', 'kFuture')

$runType = @('kRegular', 'kFull', 'kLog', 'kSystem')

$objectStatus = @{}
$allcluster = @{}

function latestStatus($objectName,
                      $registeredSource,
                      $status,
                      $scheduleType,
                      $jobName,
                      $jobType,
                      $jobId,
                      $startTimeUsecs,
                      $message,
                      $isPaused,
                      $logicalSize = 0,
                      $dataWritten = 0,
                      $dataRead = 0){

    $thisStatus = @{'status' = $status;
                    'scheduleType' = $scheduleType;
                    'registeredSource' = $registeredSource;
                    'jobName' = $jobName; 
                    'jobType' = $jobType; 
                    'jobId' = $jobId; 
                    'lastRunUsecs' = $startTimeUsecs;
                    'endTimeUsecs' = $endTimeUsecs;
                    'isPaused' = $isPaused;
                    'logicalSize' = $logicalSize;
                    'dataWritten' = $dataWritten;
                    'dataRead' = $dataRead}

    $thisStatus['message'] = $message
    $thisStatus['lastError'] = ''
    $thisStatus['lastSuccess'] = ''
    $searchJobType = $jobType
        if($jobType -eq 5){
            $searchJobType = 4
        }
    $search = api get "/searchvms?vmName=$objectName&entityTypes=$($envType[$searchJobType])"
    if($null -ne $search.vms){
        $versions = $search.vms[0].vmDocument.versions
        $thisStatus['numSnapshots'] = $versions.count 
    }else{
        $thisStatus['numSnapshots'] = 0
    }
    if($status -eq 'kSuccess'){
        $thisStatus['numErrors'] = 0
    }else{
        if($status -eq 'kFailure'){
            $thisStatus['lastError'] = $startTimeUsecs
        }
        if($search.vms.length -gt 0){
            if($status -eq 'kFailure' -or $status -eq 'kAccepted' -or $status -eq 'kRunning'){
                $thisStatus['lastSuccess'] = $search.vms[0].vmDocument.versions[0].instanceId.jobStartTimeUsecs
            }
            $runs = api get "protectionRuns?jobId=$jobId&startTimeUsecs=$($search.vms[0].vmDocument.versions[0].instanceId.jobStartTimeUsecs + 1)&excludeTasks=true&numRuns=9999"
            $thisStatus['numErrors'] = $runs.length
            if($status -eq 'kRunning'){
                $thisStatus['numErrors'] -= 1
            }
        }else{
            $thisStatus['lastSuccess'] = '?'
            $thisStatus['numErrors'] = '?'
        }
    }
    if($objectName -notin $objectStatus.Keys -or $startTimeUsecs -gt $objectStatus[$objectName].lastRunUsecs){
        $objectStatus[$objectName] = $thisStatus
    }
}


$headings = @( 'Cluster Name',
              'Object Type',
              'Object Name', 
              'Registered Source',
              'Job Name',
              'Available Snapshots',
              'Latest Status',
              'Schedule Type',
              'Last Start Time',
              'Last End Time',
              'Logical MB',
              'Read MB',
              'Written MB',
              'Change %',
              'Failure Count',
              'Error Message')



if ($weekly){   ############################################# weekly begin


#################get all startTimeusecs ##################3
$lastusecs = @()
$today = Get-Date

$7dayusec = [int64](((Get-Date).ToUniversalTime())-([datetime]"1970-01-01 00:00:00")).TotalSeconds*1000000 - (7 * 86400000000)
$6dayusec = [int64](((Get-Date).ToUniversalTime())-([datetime]"1970-01-01 00:00:00")).TotalSeconds*1000000 - (6 * 86400000000)
$5dayusec = [int64](((Get-Date).ToUniversalTime())-([datetime]"1970-01-01 00:00:00")).TotalSeconds*1000000 - (5 * 86400000000)
$4dayusec = [int64](((Get-Date).ToUniversalTime())-([datetime]"1970-01-01 00:00:00")).TotalSeconds*1000000 - (4 * 86400000000)
$3dayusec = [int64](((Get-Date).ToUniversalTime())-([datetime]"1970-01-01 00:00:00")).TotalSeconds*1000000 - (3 * 86400000000)
$2dayusec = [int64](((Get-Date).ToUniversalTime())-([datetime]"1970-01-01 00:00:00")).TotalSeconds*1000000 - (2 * 86400000000)
$ldayusec = [int64](((Get-Date).ToUniversalTime())-([datetime]"1970-01-01 00:00:00")).TotalSeconds*1000000 - 86400000000
#$ldayusec = dateToUsecs ($today.Date) - 86400000000
       $lastusecs = ( "$ldayusec","$2dayusec","$3dayusec","$4dayusec","$5dayusec","$6dayusec","7dayusec")
       #$lastusecs = ( "$ldayusec","$2dayusec","$3dayusec","$4dayusec","$5dayusec","$6dayusec")
       #$lastusecs = ( "$8dayusec")
       #$lastusecs = ( "$ldayusec")
##########################################################
 foreach ( $usecs in $lastusecs){
$clusters = ('Hcohesity05')
#$clusters = ('Hcohesity01','Hcohesity03','Hcohesity04','Hcohesity05')
#$domain = 'corpads.local'

# top of html
$prefixTitle = "($([string]::Join(", ", $prefix.ToUpper())))"
foreach ( $clusterName in $clusters) {
# authenticate
apiauth -vip $clusterName -username $username -domain corpads.local

if ($clusterName -notin $allcluster.keys){
                                          
                                          $allcluster[$clusterName]=@{}
                                          }

$objectStatus = @{}
$totalObjects = 0
$Successnum = 0
$Warningnum = 0
$Runningnum = 0
$Cancelednum = 0
$totalFailedObjects = 0
$nrecovery = 0
$Nrecoveryf = 0
$Nrecoverys = 0

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
    $includeJob = $false
    foreach($pre in $prefix){
        if ($jobName.tolower().startswith($pre.tolower()) -or $prefix -eq 'ALL') {
            $includeJob = $True
        }
    }
    if($includeJob){
        #write-host "  $jobName"
        
        #$startTimeUsecs = $job.backupJobSummary.lastProtectionRun.backupRun.base.startTimeUsecs
       # $endTimeUsecs = $job.backupJobSummary.lastProtectionRun.backupRun.base.endTimeUsecs
       $startTimeUsecs = $usecs
       $endTimeUsecs = $usecs
                            
        $jobId = $job.backupJobSummary.lastProtectionRun.backupRun.base.jobId
        if($jobId -and $startTimeUsecs){
            $lastrun = api get "/backupjobruns?allUnderHierarchy=true&StartTimeUsecs=$usecs&id=$jobId&onlyReturnDataMigrationJobs=false"
            $scheduleType = $runType[$lastrun.backupJobRuns.protectionRuns[0].backupRun.base.backupType]
            if($lastrun.backupJobRuns.protectionRuns[0].backupRun.PSObject.Properties['activeAttempt']){
                $endTimeUsecs = 0
                $message = ''
                $attempt = $lastrun.backupJobRuns.protectionRuns[0].backupRun.activeAttempt.base
                $status = $attempt.publicStatus
                $jobType = $attempt.type
                foreach($source in $attempt.sources){
                    $entity = $source.source.displayName
                    $objectName = $entity
                    latestStatus -objectName $objectName `
                                 -registeredSource $registeredSource `
                                 -status $status `
                                 -scheduleType $scheduleType `
                                 -jobName $jobName `
                                 -jobType $jobType `
                                 -jobId $jobId `
                                 -message $message `
                                 -startTimeUsecs $startTimeUsecs `
                                 -endTimeUsecs = $endTimeUsecs `
                                 -isPaused $isPaused
                }
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
        
                if($includeDatabases -and $task.PSObject.Properties['appEntityStateVec']){
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
                                     -status $appStatus `
                                     -scheduleType $scheduleType `
                                     -jobName $jobName `
                                     -jobType $jobType `
                                     -jobId $jobId `
                                     -message $message `
                                     -startTimeUsecs $startTimeUsecs `
                                     -endTimeUsecs = $endTimeUsecs `
                                     -isPaused $isPaused `
                                     -logicalSize $logicalSize `
                                     -dataWritten $dataWritten `
                                     -dataRead $dataRead
                    }
                }else{
                    $objectName = $entity
                    latestStatus -objectName $objectName `
                                 -registeredSource $registeredSource `
                                 -status $status `
                                 -scheduleType $scheduleType `
                                 -jobName $jobName `
                                 -jobType $jobType `
                                 -jobId $jobId `
                                 -message $message `
                                 -startTimeUsecs $startTimeUsecs `
                                 -endTimeUsecs = $endTimeUsecs `
                                 -isPaused $isPaused `
                                 -logicalSize $logicalSize `
                                 -dataWritten $dataWritten `
                                 -dataRead $dataRead
                }
            }
        }
    }
}                     
#########################################getting Restore reports ################
                     $NendTimeUsecs = [int64]$endTimeUsecs + 86400000000
                     $restores = api get "/restoretasks?_includeTenantInfo=true&endTimeUsecs=$NendTimeUsecs&restoreTypes=kCloneView&restoreTypes=kConvertAndDeployVMs&restoreTypes=kCloneApp&restoreTypes=kCloneVMs&restoreTypes=kDeployVMs&restoreTypes=kMountFileVolume&restoreTypes=kMountVolumes&restoreTypes=kSystem&restoreTypes=kRecoverApp&restoreTypes=kRecoverSanVolume&restoreTypes=kRecoverVMs&restoreTypes=kRestoreFiles&restoreTypes=kRecoverVolumes&restoreTypes=kDownloadFiles&restoreTypes=kRecoverEmails&restoreTypes=kRecoverDisks&startTimeUsecs=$startTimeUsecs&targetType=kLocal"

foreach ($restore in $restores){
    
    $status = ($restore.restoreTask.performRestoreTaskState.base.publicStatus).Substring(1)
    
    $nrecovery += 1
            if($status -eq 'Failure'){
                $Nrecoveryf += 1
            } else { $Nrecoverys += 1}
}

#########################restore report collection end here ###########################################################

foreach ($entity in $objectStatus.Keys | Sort-Object){
    
    $status = $objectStatus[$entity].status.Substring(1)
        $totalObjects += 1
    if ($status -eq 'Failure') { $totalFailedObjects += 1} elseif ($status -eq 'Running'){$Runningnum += 1} elseif ($status -eq 'Canceled')
    {$Cancelednum += 1} elseif ($status -eq 'Success'){$Successnum += 1} elseif($status -eq 'Warning'){$Warningnum += 1}
                              $dataWritten = $objectStatus[$entity].dataWritten
                              if($dataWritten -gt 0){
                                          $displayWritten = [math]::Round($dataWritten/(1024*1024),3) 
                                          }else{
                                              $displayWritten = 0
                                                  }
                                          $newdisplayWritten += $displayWritten
                                                     }
     
     $allcluster[$clusterName]['wtotalFailedObjects'] += $totalFailedObjects
             $allcluster[$clusterName]['wtotalObjects'] += $totalObjects
             $allcluster[$clusterName]['wRunningnum'] += $Runningnum
             $allcluster[$clusterName]['wCancelednum'] += $Cancelednum
             $allcluster[$clusterName]['wSuccessnum'] += $Successnum 
             $allcluster[$clusterName]['wWarningnum'] += $Warningnum
             $allcluster[$clusterName]['wdatawritten'] += $newdisplayWritten
             $allcluster[$clusterName]['Nrecovery'] += $nrecovery
             $allcluster[$clusterName]['Nrecoveryf'] += $Nrecoveryf
             $allcluster[$clusterName]['Nrecoverys'] += $Nrecoverys

}  ####### looping thru all clusters end
             
                
                }   ####### looping thru all usecs

                #######throw out ######

 

}  
    

          foreach ( $clusterName in $clusters) {
          $SuccessPER = (($allcluster[$clusterName].wtotalObjects - $allcluster[$clusterName].wtotalFailedObjects)/$allcluster[$clusterName].wtotalObjects).ToString("P")
          $allcluster[$clusterName]['SuccessPER'] = $SuccessPER
                                               }
          
          ##########Throw out data ##########3
          "{0,-10}  {1,-10}  {2,-10} {3,-10}  {4,-10} {5,-10}  {6,-10}  {7,-10}  {8,-10}" -f "ClusterName","Total_Object","Total_Failed","Total_Running","Total_Canceled","Total_Success","Total_Warning","Total_dataWritten_TB","Overall_Success"
         "============================================================================================================================================="

        $allcluster.GetEnumerator()| ForEach-Object  {
         
                                 $datawritten_byc = $([math]::Round($_.value.wdatawritten/(1024*1024),3))
         "{0,-10}     {1,-10}     {2,-10}    {3,-10}    {4,-10}   {5,-10}    {6,-10}     {7,-10}          {8,-10}" -f $_.name,$_.value.wtotalObjects,$_.value.wtotalFailedObjects,$_.value.wRunningnum,$_.value.wCancelednum,$_.value.wSuccessnum,$_.value.wWarningnum,$datawritten_byc,$_.value.SuccessPER

                                            $GtotalObjects += $_.value.wtotalObjects  
                                            $GSuccessnum +=   $_.value.wSuccessnum  
                                            $GWarningnum +=  $_.value.wWarningnum
                                            $GRunningnum +=  $_.value.wRunningnum
                                            $GCancelednum += $_.value.wCancelednum
                                            $GtotalFailedObjects += $_.value.wtotalFailedObjects
                                            $Gdatawritten += $datawritten_byc
                                            $GpercentFailed += ($_.value.wtotalObjects-$_.value.wtotalFailedObjects)/$_.value.wtotalObjects
                                                        }

                   $ogpercentFailed = ($GpercentFailed/4 ).ToString("P")   

    "============================================================================================================================================="
    "{0,-12}     {1,-10}     {2,-10}    {3,-10}    {4,-10}   {5,-10}    {6,-10}     {7,-10}          {8,-10}" -f "Weekly Total",$GtotalObjects,$GtotalFailedObjects,$GRunningnum,$GCancelednum,$GSuccessnum,$GWarningnum,$Gdatawritten,$ogpercentFailed

    "============================================================================================================================================="

    "=============Recovery status ================================================================================================================"
    "{0,-10}  {1,-10}  {2,-10} {3,-10}  {4,-10} " -f "ClusterName","Total_Recovery","Total_Success","Total_failed","Overall_Success"
    "============================================================================================================================================="
    $allcluster.GetEnumerator()| ForEach-Object  {
     if ( $_.value.Nrecovery -gt 0){

     $orecoverys= (( $_.value.Nrecovery - $_.value.Nrecoveryf )/ $_.value.Nrecovery).ToString("P")
     

                                   } else { $orecoverys = "0 %"}
                                 
         "{0,-10}     {1,-10}     {2,-10}    {3,-10}    {4,-10}" -f $_.name,$_.value.Nrecovery,$_.value.Nrecoverys,$_.value.Nrecoveryf,$orecoverys
                                                 
                                                 }
   
     $allcluster.GetEnumerator()| ForEach-Object  {
        
                                            $Gnrecovery += $_.value.nrecovery
                                            $GNrecoveryf +=   $_.value.Nrecoveryf  
                                            $GNrecoverys +=  $_.value.Nrecoverys
                                            
                                                        }
                                if ( $Gnrecovery -gt 0) {
                                $Gorecoverys = (($Gnrecovery - $GNrecoveryf )/$Gnrecovery).ToString("P")
                                } else { $Gorecoverys = "0 %"}


"============================================================================================================================================="
"{0,-10}     {1,-10}     {2,-10}    {3,-10}    {4,-10}" -f "Weekly_Recovery",$Gnrecovery,$GNrecoverys,$GNrecoveryf,$Gorecoverys

####################HTML coding ######################

$allcluster.GetEnumerator()| Sort-Object { $_.name}| ForEach-Object {
    
               $datawritten_byc = $([math]::Round($_.value.wdatawritten/(1024*1024),3))
                if ($_.name -in ('Hcohesity01','Hcohesity03')) {
                                        $newclusterdes = "$($_.name) -Production"

                                        } else {
                                        $newclusterdes = "$($_.name) -Non Production"
                                               }

 $HTML += "               <tr><td style='background-color: #7DE1FF;'>{0}</td>
                              <td>{1}</td>
                              <td>{2}</td>
                              <td>{3}</td>
                              <td>{4}</td>
                              <td>{5}</td>
                              <td>{6}</td>
                              <td>{7}</td>
                              <td>{8}</td></tr>" -f $newclusterdes, $_.value.wtotalObjects,$_.value.wtotalFailedObjects,$_.value.wRunningnum,$_.value.wCancelednum,$_.value.wSuccessnum,$_.value.wWarningnum,$datawritten_byc,$_.value.SuccessPER


                   #########################Finishing from all cluster #############3 
}
 $ogpercentFailed = ($GpercentFailed/4 ).ToString("P")  

 $HTML += "               <tr><td style='background-color: #8AFF8A;font-size:10.0pt'>{0}</td>
                              <td style='background-color: #8AFF8A'>{1}</td>
                              <td style='background-color: #8AFF8A'>{2}</td>
                              <td style='background-color: #8AFF8A'>{3}</td>
                              <td style='background-color: #8AFF8A'>{4}</td>
                              <td style='background-color: #8AFF8A'>{5}</td>
                              <td style='background-color: #8AFF8A'>{6}</td>
                              <td style='background-color: #8AFF8A'>{7}</td>
                              <td style='background-color: #8AFF8A'>{8}</td></tr>" -f "Week Total", $GtotalObjects,$GtotalFailedObjects,$GRunningnum,$GCancelednum,$GSuccessnum,$GWarningnum,$Gdatawritten,$ogpercentFailed

 ##########################recovery HTML code #########3333
$HTML += "
</tr><td colspan='9' style='background-color: #93C572;font-size: 28px;font-weight: bold;' >Last Week Cohesity Restore stats.</td></tr>"
$HTML += "               <tr><td colspan=2 style='background-color: #FFC300; font-size:12pt;' >{0}</td>
                              <td colspan=2 style='background-color: #FFC300; font-size:12pt;' >{1}</td>
                              <td colspan=2 style='background-color: #FFC300; font-size:12pt;' >{2}</td>
                              <td colspan=2 style='background-color: #FFC300; font-size:12pt;' >{3}</td>
                              <td style='background-color: #FFC300; font-size:12pt;'>{4}</td></tr>" -f "Cluster Name", "Number of Recovery","Success Full Recovery","Number of Failure","Overall Success"


  $allcluster.GetEnumerator()| Sort-Object { $_.name}| ForEach-Object  {
         if ($_.name -in ('Hcohesity01','Hcohesity03')) {
                                        $newclusterdes = "$($_.name) -Production"

                                        } else {
                                        $newclusterdes = "$($_.name) -Non Production"
                                               }
          if ( $_.value.Nrecovery -gt 0){
               $orecoverys= (( $_.value.Nrecovery - $_.value.Nrecoveryf )/ $_.value.Nrecovery).ToString("P")
                                        } else { $orecoverys = "0 %"}

         $HTML += "               <tr><td colspan=2 style='background-color: #7DE1FF;' >{0}</td>
                              <td colspan=2>{1}</td>
                              <td colspan=2>{2}</td>
                              <td colspan=2>{3}</td>
                              <td>{4}</td></tr>" -f $newclusterdes, $_.value.Nrecovery,$_.value.Nrecoverys,$_.value.Nrecoveryf,$orecoverys
                                
                                                 }
                                if ( $Gnrecovery -gt 0) {
                                $Gorecoverys = (($Gnrecovery - $GNrecoveryf )/$Gnrecovery).ToString("P")
                                } else { $Gorecoverys = "0 %"}
  
$HTML += "               <tr><td colspan='2' style='background-color: #8AFF8A' >{0}</td>
                              <td colspan='2' style='background-color: #8AFF8A '>{1}</td>
                              <td colspan='2' style='background-color: #8AFF8A' >{2}</td>
                              <td colspan='2' style='background-color: #8AFF8A' >{3}</td>
                              <td style='background-color: #8AFF8A' >{4}</td></tr>" -f "Week Total", $Gnrecovery,$GNrecoverys,$GNrecoveryf,$Gorecoverys


  #####################################################

$html += '
	
</div>  
</body>
</html>
'

$fileName = "./weekly_clients_summary_report.html"
$html | out-file $fileName

###################################################
### send email report
foreach($toaddr in $sendTo){
    Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Cohesity Clients Weekly Summary Report" -BodyAsHtml $html -Attachments $fileName -WarningAction SilentlyContinue
}
#copy report to NAS share
$today = get-date
$targetPath = '\\hcohesity05.corpads.local\cohesity_reports'
$year = $today.Year.ToString()
$month = $today.Month.ToString()
$date  =  $today.date.ToString('MM-dd') 
# Set Directory Path
$Directory = $targetPath + "\" + $year + "\" + $month + "\" + $date
# Create directory if it doesn't exsist
if (!(Test-Path $Directory))
{
New-Item $directory -type directory
}
# copy File to NAS location
$filename | Copy-Item -Destination $Directory

﻿# usage:
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
    [Parameter()][string]$domain = 'local', #local or AD domain
    [Parameter()][array]$prefix = 'ALL', #report jobs with 'prefix' only
    [Parameter(Mandatory = $True)][string]$smtpServer, #outbound smtp server '192.168.1.95'
   # [Parameter()][switch]$includeDatabases, #switch to include individual databases or not
    [Parameter()][string]$smtpPort = 25, #outbound smtp port
    [Parameter(Mandatory = $True)][array]$sendTo, #send to address
    [Parameter(Mandatory = $True)][string]$sendFrom #send from address
)

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

# authenticate
apiauth -vip $vip -username $username -domain $domain
# get cluster info
$cluster = api get cluster

$outFile = $(Join-Path -Path $PSScriptRoot -ChildPath "DailyStatus_Report-$($cluster.name).csv")
"Object Type,Object Name,Registered Source,Job Name,Available Snapshots,Latest Status,Schedule Type,Last Start Time,Last End Time,Logical MB,Read MB,Written MB,Change %,Failure Count,Error Message" | Out-File -FilePath $outFile



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
function tdhead($data, $color){
    '<td colspan="1" bgcolor="#' + $color + '" valign="top" align="CENTER" border="0"><font size="2">' + $data + '</font></td>'
}
function td($data, $color, $wrap='', $align='LEFT'){
    '<td ' + $wrap + ' colspan="1" bgcolor="#' + $color + '" valign="top" align="' + $align + '" border="0"><font size="2">' + $data + '</font></td>'
}

# top of html
$prefixTitle = "($([string]::Join(", ", $prefix.ToUpper())))"

$html = '<html><div style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;"><font face="Tahoma" size="+3" color="#000080">
<center>Backup Job Summary Report<br>
<font size="+2">Backup Job Summary Report - ' + $prefixTitle + ' Daily Backup Report</font></center>
</font>
<hr>
Report generated on ' + (get-date) + '<br>
Cohesity Cluster: ' + $cluster.name + '<br>
Cohesity Version: ' + $cluster.clusterSoftwareVersion + '<br>
<br></div>'

$html += '<table align="center" border="0" cellpadding="4" cellspacing="1" style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;">
<tbody><tr><td colspan="15" align="CENTER" valign="TOP" bgcolor="#000080"><font size="+1" color="#FFFFFF">Summary</font></td></tr><tr bgcolor="#FFFFFF">'

$headings = @('Object Type',
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

foreach($heading in $headings){
    $html += td $heading 'CCCCCC' '' 'CENTER'
}
$html += '</tr>'
$nowrap = 'nowrap'

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

# populate html rows
foreach ($entity in $objectStatus.Keys | Sort-Object){
    $app = ''
    $objectName = $entity
    $environment = $envType[$objectStatus[$entity].jobType].Substring(1)
    if($entity.contains('/') -and $environment -in @('SQL', 'Oracle')){
        $objectName, $app = $entity.split('/',2)
    }
    $environment = $envType[$objectStatus[$entity].jobType].Substring(1)
    $registeredSource = $objectStatus[$entity].registeredSource
    $scheduleType = $objectStatus[$entity].scheduleType.Substring(1)
    $status = $objectStatus[$entity].status.Substring(1)
    $jobName = $objectStatus[$entity].jobName
    $numSnapshots = $objectStatus[$entity].numSnapshots
    $message = $objectStatus[$entity].message
    $jobId = $objectStatus[$entity].jobId
    $jobUrl = "https://$vip/protection/job/$jobId/details"
    $lastRunStartTime = usecsToDate $objectStatus[$entity].lastRunUsecs
    $endTimeUsecs = $objectStatus[$entity].endTimeUsecs
    if($endTimeUsecs -eq 0){
        $endTime = ''
    }else{
        $endTime = usecsToDate $endTimeUsecs
    }
    $isPaused = $objectStatus[$entity].isPaused
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
    $numErrors = $objectStatus[$entity].numErrors
    if($numErrors -eq 0){ $numErrors = ''}
    $lastRunErrorMsg = $objectStatus[$entity].message
    if($status -eq 'Warning'){
        $color = 'F3F387'
    }elseif($status -eq 'Failure'){
        $color='FF9292'
    }elseif($status -eq 'Success'){
        $color='CCFFCC'
    }elseif($status -eq 'Accepted'){
        $color='9DCEF3'
    }elseif($status -eq 'Running'){
        $color='9DCEF3'
    }elseif($status -eq 'Canceled'){
        $color='F3BB76'
    }
    if($isPaused -eq $True){
        $color='CC99FF'
    }
    $html += '<tr>'
    $html += td $environment $color ''
    $html += td $objectName $color ''
    #$html += td $app $color ''
    $html += td $registeredSource $color ''
    $html += td "<a target=`"_blank`" href=$jobUrl>$jobName</a>" $color $nowrap 'CENTER'
    $html += td $numSnapshots $color '' 'CENTER'
    $html += td $status $color $nowrap 'CENTER'
    $html += td $scheduleType $color '' 'CENTER'
    $html += td $lastRunStartTime $color '' 'CENTER'
    $html += td $endTime $color '' 'CENTER'
    #$html += td $lastSuccessfulRunTime $color '' 'CENTER'
    $html += td $displaySize $color
    $html += td $displayRead $color
    $html += td $displayWritten $color
    if($changeRatePct -ge 10){
        $html += td $changeRatePct 'DAB0B0'
    }else{
        $html += td $changeRatePct $color
    }
    $html += td $numErrors $color $nowrap 'CENTER'
    $html += td $lastRunErrorMsg $color
    $html += '</tr>'
    "{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14}" -f $environment,$objectName,$registeredSource,$jobName,$numSnapshots,$status,$scheduleType,$lastRunStartTime,$endTime,$displaySize,$displayRead,$displayWritten,$changeRatePct,$numErrors,$lastRunErrorMsg | out-file -FilePath $outfile -Append


}

# end of html
$html += '</tbody></table><br>
<table align="center" border="1" cellpadding="4" cellspacing="0" style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;">
<tbody>
<tr>
<td bgcolor="#9DCEF3" valign="top" align="center" border="0" width="100"><font size="1">Running</font></td>
<td bgcolor="#CC99FF" valign="top" align="center" border="0" width="100"><font size="1">Paused</font></td>
<td bgcolor="#CCFFCC" valign="top" align="center" border="0" width="100"><font size="1">Completed</font></td>
<td bgcolor="#F3F387" valign="top" align="center" border="0" width="100"><font size="1">Completed with warnings</font></td>
<td bgcolor="#F3BB76" valign="top" align="center" border="0" width="100"><font size="1">Cancelled</font></td>
<td bgcolor="#FF9292" valign="top" align="center" border="0" width="100"><font size="1">Failed</font></td>
<td bgcolor="#DAB0B0" valign="top" align="center" border="0" width="100"><font size="1">Change Rate &gt; 10%</font></td>
</tr>
</tbody>
</table>
</html>'

$outFilePath = join-path -Path $PSScriptRoot -ChildPath 'objectreport.html'
$html | Out-File -FilePath 'objectreport.html' -Encoding ascii
#$html | Out-File -FilePath 'storageGrowth.html' -Encoding ascii
#.$outFilePath
$attachfile = @("$outfile")
#send email report
write-host "sending report to $([string]::Join(", ", $sendTo))"
foreach($toaddr in $sendTo){
    Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "$prefixTitle backupSummaryReport ($($cluster.name))" -BodyAsHtml $html -WarningAction SilentlyContinue -Attachments $attachfile
}
#$html | out-file "$($cluster.name)-sql_report.html"
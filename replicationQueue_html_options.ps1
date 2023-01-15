 ### process commandline arguments
[CmdletBinding()]
param (
    [Parameter()][array]$vips,
    [Parameter()][string]$username = 'helios',
    [Parameter()][string]$domain = 'local',
    [Parameter()][string]$tenant,
    [Parameter()][switch]$useApiKey,
    [Parameter()][string]$password,
    [Parameter()][switch]$noPrompt,
    [Parameter()][switch]$mcm,
    [Parameter()][switch]$oldest,
    [Parameter()][switch]$listjobonly,
    [Parameter()][switch]$oldestbyallJob,  ### Print every jobs oldest entry
    [Parameter()][string]$mfaCode,
    [Parameter()][switch]$emailMfaCode,
    [Parameter()][string]$clusterName,
    [Parameter()][array]$jobName, #jobs for which user wants to list/cancel replications
    [Parameter()][string]$joblist = '',
    [Parameter()][int]$numRuns = 999,
    [Parameter()][switch]$cancelAll,
    [Parameter()][switch]$cancelOutdated,
    [Parameter()][string]$smtpServer, #outbound smtp server '192.168.1.95'
[Parameter()][string]$smtpPort = 25, #outbound smtp port
[Parameter()][array]$sendTo, #send to address
[Parameter()][string]$sendFrom #send from address
)

# start gathering output from script
#Start-Transcript -Append C:\anil\scripts\PSScriptLog.txt
$htmlFileName = "Latest_replication_status.html"

#################HTML#############
$html = '<html>
<head>
    <style>
                h1 {
            background-color:#b1ffb1;
            }

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
            color: #333333;
            font-size: 0.75em;
            border-collapse: collapse;
            width: 100%;
        }
        tr {
            border: 1px solid #F1F1F1;
        }
        td,
        th {
            width: 33%;
            text-align: left;
            padding: 6px;
        }
        tr:nth-child(even) {
            background-color: #F1F1F1;
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
            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
            8LK0YAAAAASUVORK5CYII=" style="width:180px">
        <p style="margin-top: 15px; margin-bottom: 15px;">
            <span style="font-size:1.3em;">'


$html += '</span>
<span style="font-size:0.75em; text-align: right; padding-top: 8px; padding-right: 2px; float: right;">'
$html += $date
# gather list from command line params and file
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

$jobNames = @(gatherList -Param $jobName -FilePath $jobList -Name 'jobs' -Required $false)

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

$clusterstats = @{}

if($vips){
$vips = @($vips) }else {
#$vips = ("cohwpcu01")
#$vips = ("cohwpcu01","cohsdcu01")
#$vips = ('chyusnpccp02','chyuswpccp02')
#$vips = ('chyusnpccp03','chyusnpccp01','chyuswpccp01','chyuswpccp03')
#$vips = ('chyusnpccp01','chyusnpccp02','chyusnpccp03','chyusnpccp05','chyuswpccp01','chyuswpccp02','chyuswpccp03','chyuswpccp05','chyukpccp01','chyukrccp01','chysgpccp01','chysgrccp01','chymaidcp01','chyididcp01')
$vips = ('chyusnpccp01','chyuswpccp01','chyusnpccp02','chyuswpccp02','chyusnpccp03','chyuswpccp03','chyusnpccp05','chyuswpccp05')
                     }

foreach ($vip in $vips){

# authenticate
apiauth -vip $vip -username $username -domain $domain -passwd $password -apiKeyAuthentication $useApiKey -mfaCode $mfaCode -sendMfaCode $emailMfaCode -heliosAuthentication $mcm -regionid $region -tenant $tenant -noPromptForPassword $noPrompt

"============= Working on $vip   =============="
if ($vip -notin $clusterstats.keys){
                         $clusterstats[$vip] = @{}
                                           }
# select helios/mcm managed cluster
if($USING_HELIOS -and !$region){
    if($clusterName){
        $thisCluster = heliosCluster $clusterName
    }else{
        write-host "Please provide -clusterName when connecting through helios" -ForegroundColor Yellow
        exit 1
    }
}

if(!$cohesity_api.authorized){
    Write-Host "Not authenticated"
    exit 1
}

$jobs = api get protectionJobs | Where-Object {$_.isDeleted -ne $True -and $_.isActive -ne $false}

# catch invalid job names
if($jobNames.Count -gt 0){
    $notfoundJobs = $jobNames | Where-Object {$_ -notin $jobs.name}
    if($notfoundJobs){
        Write-Host "Jobs not found $($notfoundJobs -join ', ')" -ForegroundColor Yellow
    }
}

$finishedStates = @('kCanceled', 'kSuccess', 'kFailure', 'kWarning')

$nowUsecs = dateToUsecs (get-date)

$runningTasks = @{}

foreach($job in $jobs | Sort-Object -Property name){
    $jobId = $job.id
    $thisJobName = $job.name
    if($jobNames.Count -eq 0 -or $thisJobName -in $jobNames){
        #"Getting tasks for $thisJobName"
        $runs = api get "protectionRuns?jobId=$jobId&numRuns=$numRuns&excludeTasks=true" | Where-Object {$_.copyRun.status -notin $finishedStates }
        foreach($run in $runs){
            $runStartTimeUsecs = $run.backupRun.stats.startTimeUsecs
            foreach($copyRun in $($run.copyRun | Where-Object {$_.status -notin $finishedStates})){
                $startTimeUsecs = $runStartTimeUsecs
                $copyType = $copyRun.target.type
                $status = $copyRun.status
                if($copyType -eq 'kRemote'){
                    $runningTask = @{
                        "jobname" = $thisJobName;
                        "jobId" = $jobId;
                        "startTimeUsecs" = $runStartTimeUsecs;
                        "copyType" = $copyType;
                        "status" = $status
                    }
                    $runningTasks[$startTimeUsecs] = $runningTask
                }
            }
        }
    }
}

###################List job names with their oldest running date ############

# display output sorted by oldest first
if($listjobonly){
            if($runningTasks.Keys.Count -gt 0){

                                            
            "`n`nStart Time                  Job Name"
    "----------                  --------"
    foreach($startTimeUsecs in ($runningTasks.Keys | Sort-Object)){
        $t = $runningTasks[$startTimeUsecs]
        "{0,-25}   {1,-30}          ({2})" -f (usecsToDate $t.startTimeUsecs), $t.jobName, $t.jobId
                                 
                                                                }
                                               }
                                               exit
                 }
###########################################################################

# display output sorted by oldest first
if($runningTasks.Keys.Count -gt 0){

                      if ($oldest){

                      
    "`n`nStart Time           Job Name"
    "----------           --------"
    $startTimeUsecs = $($runningTasks.Keys| Sort-Object)[0]
    
        $t = $runningTasks[$startTimeUsecs]

        
                    #$dt = (usecsToDate $t.startTimeUsecs).Tostring().replace(' ','-').replace('/','-').replace(':','-')
                    $dt = (usecsToDate $t.startTimeUsecs).Tostring("MM/dd/yyyy hh:mmtt")
            $clusterstats[$vip]['starttime'] = $dt
            $clusterstats[$vip]['jobname']   = $t.jobName

        "{0}   {1} ({2})" -f (usecsToDate $t.startTimeUsecs), $t.jobName, $t.jobId
        $run = api get "/backupjobruns?allUnderHierarchy=true&exactMatchStartTimeUsecs=$($t.startTimeUsecs)&id=$($t.jobId)"
        $runStartTimeUsecs = $run.backupJobRuns.protectionRuns[0].backupRun.base.startTimeUsecs
        foreach($task in $run.backupJobRuns.protectionRuns[0].copyRun.activeTasks){
            if($task.snapshotTarget.type -eq 2){

                $noLongerNeeded = ''
                $daysToKeep = $task.retentionPolicy.numDaysToKeep
                $usecsToKeep = $daysToKeep * 1000000 * 86400
                $timePassed = $nowUsecs - $runStartTimeUsecs
                if($timePassed -gt $usecsToKeep){
                    $noLongerNeeded = "NO LONGER NEEDED"
                }
                "                       Replication Task ID: {0}  {1}" -f $task.taskUid.objectId, $noLongerNeeded
                $clusterstats[$vip]['Notneeded']   = $noLongerNeeded

                foreach($subTask in $task.activeCopySubTasks | Sort-Object {$_.publicStatus} -Descending){
                    if($subTask.snapshotTarget.type -eq 2){
                        if($subTask.publicStatus -eq 'kRunning'){
                            $pct = $subTask.replicationInfo.pctCompleted
                        }else{
                            $pct = 0
                        }
                        "                       {0} ({1})`t{2}" -f $subTask.publicStatus, $pct, $subTask.entity.displayName
                                                 $clusterstats[$vip]['status']   = $subTask.publicStatus
                                                 $clusterstats[$vip]['pct']   = $pct
                                                 $clusterstats[$vip]['client']   = $subTask.entity.displayName
                    }
                }
                if($cancelAll -or ($cancelOutdated -and ($noLongerNeeded -eq "NO LONGER NEEDED"))){
                    $cancelTaskParams = @{
                        "jobId"       = $t.jobId;
                        "copyTaskUid" = @{
                            "id"                   = $task.taskUid.objectId;
                            "clusterId"            = $task.taskUid.clusterId;
                            "clusterIncarnationId" = $task.taskUid.clusterIncarnationId
                        }
                    }
                    $null = api post "protectionRuns/cancel/$($t.jobId)" $cancelTaskParams 
                }
            }
        }
    


                                  }elseif ($oldestbyallJob){   ### Print every jobs oldest entry
                                  $html += '</table>
                                <p style="margin-top: 15px; margin-bottom: 15px;">Cohesity Cluster: <span style="font-size:1.5em;">' + $vip + '</span></p>               
                                
                                </div>
                                </body>
                                </html>'
                                  $jobstats =@()
                                  
                                  $html += '</span>
                                            </p>
                                            <table>
                                            <tr>
                                                    <th>Job Nmae</th>
                                                    <th>Job Start Time</th>
                                                    <th>Status</th>
                                                    <th>Client Replicating</th>
                                                    <th>Percentage Completed</th>
                                                    <th>Replication Needed</th>
                                                    </tr>'
                                  
                                "`n`nStart Time           Job Name"
                                "----------           --------"
                                foreach($startTimeUsecs in ($runningTasks.Keys | Sort-Object)){
                                    $t = $runningTasks[$startTimeUsecs]
                                    "{0}   {1} ({2})" -f (usecsToDate $t.startTimeUsecs), $t.jobName, $t.jobId
                                    if ($t.jobName -notin $jobstats){
                                    $jobstats += $t.jobName
                                    $run = api get "/backupjobruns?allUnderHierarchy=true&exactMatchStartTimeUsecs=$($t.startTimeUsecs)&id=$($t.jobId)"
                                    $runStartTimeUsecs = $run.backupJobRuns.protectionRuns[0].backupRun.base.startTimeUsecs
                                    foreach($task in $run.backupJobRuns.protectionRuns[0].copyRun.activeTasks){
                                        if($task.snapshotTarget.type -eq 2){

                                            $noLongerNeeded = ''
                                            $daysToKeep = $task.retentionPolicy.numDaysToKeep
                                            $usecsToKeep = $daysToKeep * 1000000 * 86400
                                            $timePassed = $nowUsecs - $runStartTimeUsecs
                                            if($timePassed -gt $usecsToKeep){
                                                $noLongerNeeded = "NO LONGER NEEDED"
                                            }
                                            "                       Replication Task ID: {0}  {1}" -f $task.taskUid.objectId, $noLongerNeeded
                                            foreach($subTask in $task.activeCopySubTasks | Sort-Object {$_.publicStatus} -Descending){
                                                if($subTask.snapshotTarget.type -eq 2){
                                                    if($subTask.publicStatus -eq 'kRunning'){
                                                        $pct = $subTask.replicationInfo.pctCompleted
                                                    }else{
                                                        $pct = 0
                                                    }
                                                    "                       {0} ({1})`t{2}" -f $subTask.publicStatus, $pct, $subTask.entity.displayName
                                                }
                                            }
                                            
                                            
                                                                    }
                                            if($cancelAll -or ($cancelOutdated -and ($noLongerNeeded -eq "NO LONGER NEEDED"))){
                                                $cancelTaskParams = @{
                                                    "jobId"       = $t.jobId;
                                                    "copyTaskUid" = @{
                                                        "id"                   = $task.taskUid.objectId;
                                                        "clusterId"            = $task.taskUid.clusterId;
                                                        "clusterIncarnationId" = $task.taskUid.clusterIncarnationId
                                                    }
                                                }
                                                $null = api post "protectionRuns/cancel/$($t.jobId)" $cancelTaskParams 
                                            }
                                        } ##############Populate HTML ##############
                                                     
                                                     $html += "<tr>         <td>$($t.jobName)</td>
                                                                            <td>$($((usecsToDate $t.startTimeUsecs).Tostring("MM/dd/yyyy hh:mmtt")))</td>
                                                                            <td>$($subTask.publicStatus)</td>
                                                                            <td>$($subTask.entity.displayName)</td>
                                                                            <td>$($pct)</td>
                                                                            <td>$($noLongerNeeded)</td>
                                                                        </tr>"

                                                             

                                #################################################
                                        #####################end HTML #######
                                    }
                                } #### print oldest entry for each job

                                

                                           }else { ###all entry


    "`n`nStart Time           Job Name"
    "----------           --------"
    foreach($startTimeUsecs in ($runningTasks.Keys | Sort-Object)){
        $t = $runningTasks[$startTimeUsecs]
        "{0}   {1} ({2})" -f (usecsToDate $t.startTimeUsecs), $t.jobName, $t.jobId
        $run = api get "/backupjobruns?allUnderHierarchy=true&exactMatchStartTimeUsecs=$($t.startTimeUsecs)&id=$($t.jobId)"
        $runStartTimeUsecs = $run.backupJobRuns.protectionRuns[0].backupRun.base.startTimeUsecs
        foreach($task in $run.backupJobRuns.protectionRuns[0].copyRun.activeTasks){
            if($task.snapshotTarget.type -eq 2){

                $noLongerNeeded = ''
                $daysToKeep = $task.retentionPolicy.numDaysToKeep
                $usecsToKeep = $daysToKeep * 1000000 * 86400
                $timePassed = $nowUsecs - $runStartTimeUsecs
                if($timePassed -gt $usecsToKeep){
                    $noLongerNeeded = "NO LONGER NEEDED"
                }
                "                       Replication Task ID: {0}  {1}" -f $task.taskUid.objectId, $noLongerNeeded
                foreach($subTask in $task.activeCopySubTasks | Sort-Object {$_.publicStatus} -Descending){
                    if($subTask.snapshotTarget.type -eq 2){
                        if($subTask.publicStatus -eq 'kRunning'){
                            $pct = $subTask.replicationInfo.pctCompleted
                        }else{
                            $pct = 0
                        }
                        "                       {0} ({1})`t{2}" -f $subTask.publicStatus, $pct, $subTask.entity.displayName
                    }
                }
                if($cancelAll -or ($cancelOutdated -and ($noLongerNeeded -eq "NO LONGER NEEDED"))){
                    $cancelTaskParams = @{
                        "jobId"       = $t.jobId;
                        "copyTaskUid" = @{
                            "id"                   = $task.taskUid.objectId;
                            "clusterId"            = $task.taskUid.clusterId;
                            "clusterIncarnationId" = $task.taskUid.clusterIncarnationId
                        }
                    }
                    $null = api post "protectionRuns/cancel/$($t.jobId)" $cancelTaskParams 
                }
            }
        }
    } ####main script
                                   } #if not oldest
}else{                              ## no task found

    "`nNo active replication tasks found"
    if ($oldest){
    $clusterstats[$vip]['jobname']   = "No active replication tasks found"}else {
                                    
                                    $html += '</table>
                                <p style="margin-top: 15px; margin-bottom: 15px;">Cohesity Cluster: <span style="font-size:1.5em;">' + $vip + '</span></p>               
                                
                                </div>
                                </body>
                                </html>'
                                        
                                    $html += '</table>
                                <p style="margin-top: 15px; margin-bottom: 15px;">No active replication found. </p>               
                                
                                </div>
                                </body>
                                </html>'
                                    
                                    #$html += '<p><span style="color:green">No active replication tasks found</span></p>'
                                   #$html += "<tr><td>No active replication tasks found</td> </tr>"
                                  }
}

          }  #### VIPS looping
# stop capturing console output to loggin file
#Stop-Transcript
if ($oldest){
$html += '</span>
</p>
<table>
<tr>
        <th>Cluster Name</th>
        <th>Job Nmae</th>
        <th>Job Start Time</th>
        <th>Status</th>
        <th>Client Replicating</th>
        <th>Percentage Completed</th>
        <th>Replication Needed</th>
        </tr>'


################################
#$clusterstats|ConvertTo-Json

$clusterstats.GetEnumerator()|sort-object -Property {$_.key} |foreach {

#"{0}  {1} {2}  {3} {4}  {5} {6}" -f $_.key,$_.value.jobname,$($_.value.starttime),$_.value.status,$_.value.client,$_.value.pct

                                  $html += "<tr>
    <td>$($_.key)</td>
    <td>$($_.value.jobname)</td>
    <td>$($_.value.starttime)</td>
    <td>$($_.value.status)</td>
    <td>$($_.value.client)</td>
    <td>$($_.value.pct)</td>
    <td>$($_.value.Notneeded)</td>
</tr>"
                                     } 

                                     } ###HTML table formating for $oldest #######

                                     $html += "
</table>                
</div>
</body>
</html>"

$html | out-file $htmlFileName


# send email report
#write-host "sending report to $([string]::Join(", ", $sendTo))"
foreach($toaddr in $sendTo){
   Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Current Replication stats from ALL US Cohesity cluster." -BodyAsHtml $html -WarningAction SilentlyContinue }
#$html | out-file "$($cluster.name)-objectreport.html"


#copy report to NAS share
$today = get-date
$targetPath = '\\cohwpcu01.ent.ad.ntrs.com\cohesity_reports'
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
$htmlFileName | Copy-Item -Destination $Directory

### process commandline arguments
[CmdletBinding()]
param (
    [Parameter()][string]$vip='helios.cohesity.com',
    [Parameter()][string]$username = 'helios',
    [Parameter()][string]$domain = 'local',
    [Parameter()][string]$tenant,
    [Parameter()][switch]$useApiKey,
    [Parameter()][string]$password,
    [Parameter()][switch]$noPrompt,
    [Parameter()][switch]$mcm,
    [Parameter()][switch]$oldest,
    [Parameter()][switch]$listjobonly,
    [Parameter()][string]$startdate,      # start of date range to report on (e.g. -startDate '2019-08-01')
    [Parameter()][string]$enddate,         #end of date range to report on (e.g. -endDate '2019-09-01')
    [Parameter()][switch]$cancelselected,  #works with $startdate and $enddate
    [Parameter()][switch]$list,            # works with $startdate and $enddate
    [Parameter()][string]$mfaCode,
    [Parameter()][switch]$emailMfaCode,
    [Parameter()][string]$clusterName,
    [Parameter()][array]$jobName, #jobs for which user wants to list/cancel replications
    [Parameter()][string]$joblist = '',
    [Parameter()][int]$numRuns = 999,
    [Parameter()][switch]$cancelAll,
    [Parameter()][switch]$cancelOutdated
)

# start gathering output from script
#Start-Transcript -Append C:\anil\scripts\PSScriptLog.txt

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


if ($startDate -and $endDate){
$uStart = dateToUsecs $startDate
$uEnd = dateToUsecs $endDate }

# authenticate
apiauth -vip $vip -username $username -domain $domain -passwd $password -apiKeyAuthentication $useApiKey -mfaCode $mfaCode -sendMfaCode $emailMfaCode -heliosAuthentication $mcm -regionid $region -tenant $tenant -noPromptForPassword $noPrompt

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
        "Getting tasks for $thisJobName"
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
    


                                  }elseif($startdate -and $enddate){
################################ cancel selected dates###########################################

    "`n`nStart Time           Job Name"
    "----------           --------"
    foreach($startTimeUsecs in ($runningTasks.Keys | Sort-Object) ){
             if ($startTimeUsecs -ge $ustart -and $startTimeUsecs -le $uend){
        $t = $runningTasks[$startTimeUsecs]
        
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
                        if($list){
                        "{0}   {1} ({2})" -f (usecsToDate $t.startTimeUsecs), $t.jobName, $t.jobId
                        "                       {0} ({1})`t{2}" -f $subTask.publicStatus, $pct, $subTask.entity.displayName
                        }
                    }
                }
                if($cancelselected){
                    $cancelTaskParams = @{
                        "jobId"       = $t.jobId;
                        "copyTaskUid" = @{
                            "id"                   = $task.taskUid.objectId;
                            "clusterId"            = $task.taskUid.clusterId;
                            "clusterIncarnationId" = $task.taskUid.clusterIncarnationId
                        }
                    }
                    "Cancelling ........."
                    "{0}   {1} ({2})" -f (usecsToDate $t.startTimeUsecs), $t.jobName, $t.jobId
                    $null = api post "protectionRuns/cancel/$($t.jobId)" $cancelTaskParams 
                }
            }
        }
        }
    } ####main script
                                  
                                  
                                  
###############################################################3#################################                       
                                  }else{ ###all entry


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
}else{
    "`nNo active replication tasks found"
}
# stop capturing console output to loggin file
#Stop-Transcript
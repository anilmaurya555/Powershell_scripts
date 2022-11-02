﻿# usage: ./backupNow.ps1 -vip mycluster -username myusername -domain mydomain.net -jobName 'My Job' -keepLocalFor 5 -archiveTo 'My Target' -keepArchiveFor 5 -replicateTo mycluster2 -keepReplicaFor 5 -enable

# process commandline arguments
[CmdletBinding()]
param (
    [Parameter()][string]$vip = 'helios.cohesity.com',  # the cluster to connect to (DNS name or IP)
    [Parameter()][string]$username = 'helios',  # username (local or AD)
    [Parameter()][string]$domain = 'local',  # local or AD domain
    [Parameter()][string]$clusterName = $null,  # helios cluster to access 
    [Parameter(Mandatory = $True)][string]$jobName,  # job to run
    [Parameter(Mandatory = $True)][string]$client,  # client to archive
    [Parameter()][int]$keepLocalFor = 5,  # keep local snapshot for x days
    [Parameter()][string]$replicateTo = $null,  # optional - remote cluster to replicate to
    [Parameter()][int]$keepReplicaFor = 5,  # keep replica for x days
    [Parameter()][string]$archiveTo = $null,  # optional - target to archive to
    [Parameter()][int]$keepArchiveFor = 5,  # keep archive for x days
    [Parameter()][switch]$enable,  # enable a disabled job, run it, then disable when done
    [Parameter()][ValidateSet('kRegular','kFull','kLog','kSystem')][string]$backupType = 'kRegular',
    [Parameter()][array]$objects,
    [Parameter()][switch]$progress,
    [Parameter()][switch]$wait,
    [Parameter()][switch]$helios
)

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

apiauth -vip $vip -username $username -domain $domain

if($USING_HELIOS){
    if($clusterName){
        heliosCluster $clusterName
    }else{
        write-host "Please provide -clusterName when connecting through helios" -ForegroundColor Yellow
        exit 1
    }
}

# build list of sourceIds if specified
$sources = @{}

function getObjectId($objectName){
    $global:_object_id = $null

    function get_nodes($obj){
        if($obj.protectionSource.name -eq $objectName){
            $global:_object_id = $obj.protectionSource.id
            break
        }
        if($obj.name -eq $objectName){
            $global:_object_id = $obj.id
            break
        }        
        if($obj.PSObject.Properties['nodes']){
            foreach($node in $obj.nodes){
                if($null -eq $global:_object_id){
                    get_nodes $node
                }
            }
        }
    }
    
    foreach($source in $sources){
        if($null -eq $global:_object_id){
            get_nodes $source
        }
    }
    return $global:_object_id
}

# get cluster id
$cluster = api get cluster

# find the jobID
$job = (api get protectionJobs | Where-Object name -ieq $jobName)
if($job){
    if($job.policyId.split(':')[0] -ne $cluster.id){
        Write-Host "Job $jobName is not local to the cluster $($cluster.name)" -ForegroundColor Yellow
        exit 1
    }
    $jobID = $job.id
    $environment = $job.environment
    if($environment -notin ('kOracle', 'kSQL') -and $backupType -eq 'kLog'){
        Write-Warning "BackupType kLog not applicable to $environment jobs"
        exit 1
    }
    if($objects){
        if($environment -eq 'kSQL'){
            $sources = api get "protectionSources?environments=$environment"
            $sources = $sources.nodes | where-object { $_.protectionSource.id -in $job.sourceIds }
        }else{
            $sources = api get "protectionSources/objects?objectIds=$($job.sourceIds -join ',')"
        }
    }
}else{
    Write-Warning "Job $jobName not found!"
    exit 1
}

# handle SQL DB run now objects
if($environment -eq 'kSQL' -and $job.environmentParameters.sqlParameters.backupType -eq 'kSqlVSSFile'){
    if($objects){
        $runNowParameters = @()
        foreach($object in $objects){
            $server, $instance, $db = $object.split('/')
            $serverObjectId = getObjectId $server
            if($serverObjectId){
                if(! ($runNowParameters | Where-Object {$_.sourceId -eq $serverObjectId})){
                    $runNowParameters += @{
                        "sourceId" = $serverObjectId;
                    }
                    if($instance -or $db){
                        ($runNowParameters | Where-Object {$_.sourceId -eq $serverObjectId}).databaseIds = @()
                    }
                }
                $serverSource = api get "protectionSources?id=$serverObjectId"
                if($serverSource.PSObject.Properties['applicationNodes']){
                    $instanceNodes = $serverSource.applicationNodes
                    if($instance){
                        $instanceNode = $instanceNodes | Where-Object {$_.protectionSource.Name -eq $instance }
                        if($instanceNode){
                            if(! $db){
                                if($instanceNode.protectionSource.id -in $job.sourceSpecialParameters.sqlSpecialParameters.applicationEntityIds -or ! ($job.sourceSpecialParameters | Where-Object {$_.sourceId -eq $serverObjectId})){
                                    ($runNowParameters | Where-Object {$_.sourceId -eq $serverObjectId}).databaseIds += $instanceNode.protectionSource.id
                                }else{
                                    $dbNodes = $instanceNode.nodes
                                    foreach($dbNode in $dbNodes){
                                        if($dbNode.protectionSource.id -in $job.sourceSpecialParameters.sqlSpecialParameters.applicationEntityIds){
                                            ($runNowParameters | Where-Object {$_.sourceId -eq $serverObjectId}).databaseIds += $dbNode.protectionSource.id
                                        }
                                    }
                                }
                            }else{
                                $dbNode = $instanceNode.nodes | Where-Object {$_.protectionSource.Name -eq "$instance/$db"}
                                    if($dbNode){
                                        if($dbNode.protectionSource.id -in $job.sourceSpecialParameters.sqlSpecialParameters.applicationEntityIds -or $instanceNode.protectionSource.id -in $job.sourceSpecialParameters.sqlSpecialParameters.applicationEntityIds){
                                            ($runNowParameters | Where-Object {$_.sourceId -eq $serverObjectId}).databaseIds += $dbNode.protectionSource.id
                                        }else{
                                            write-host "DB $db not protected by job" -ForegroundColor Yellow
                                            exit 1
                                        }
                                    }else{
                                        write-host "Object $object not found (db name)" -ForegroundColor Yellow
                                        exit 1
                                    }
                            } 
                        }else{
                            write-host "instance $instance not found" -ForegroundColor Yellow
                            exit 1
                        }
                    }else{
                        if($job.sourceSpecialParameters | Where-Object {$_.sourceId -eq $serverObjectId}){
                            foreach($dbId in ($job.sourceSpecialParameters | Where-Object {$_.sourceId -eq $serverObjectId})){
                                ($runNowParameters | Where-Object {$_.sourceId -eq $serverObjectId}).databaseIds += $dbId
                            }
                        }
                    }
                }else{
                    write-host "Object $object not found (server name)" -ForegroundColor Yellow
                    exit 1
                }
            }else{
                write-host "Object $object not found (server name)" -ForegroundColor Yellow
                exit 1
            }
        }
    }
}elseif ($environment -eq 'kOracle') {
    if($objects){
        $runNowParameters = @()
        foreach($object in $objects){
            $server, $db = $object.split('/')
            $serverObjectId = getObjectId $server
            if($serverObjectId){
                if(! ($runNowParameters | Where-Object {$_.sourceId -eq $serverObjectId})){
                    $runNowParameters += @{
                        "sourceId" = $serverObjectId;
                        "databaseIds" = @()
                    }
                }
                $serverSource = api get "protectionSources?id=$serverObjectId"
                if($serverSource.PSObject.Properties['applicationNodes']){
                    $dbNodes = $serverSource.applicationNodes
                    $job.sourceSpecialParameters | ConvertTo-Json -Depth 99
                    if($db){
                        $dbNodes = @($dbNodes | Where-Object {$_.protectionSource.Name -eq $db})
                        if(! $dbNodes){
                            write-host "Object $object not found (db name)" -ForegroundColor Yellow
                            exit 1
                        }
                    }
                    foreach($dbNode in $dbNodes){
                        if($dbNode -and $dbNode.protectionSource.id -in $job.sourceSpecialParameters.oracleSpecialParameters.applicationEntityIds){
                            $dbId = $dbNode.protectionSource.id
                            ($runNowParameters | Where-Object {$_.sourceId -eq $serverObjectId}).databaseIds += $dbId
                        }else{
                            write-host "Object $object not found (db name)" -ForegroundColor Yellow
                            exit 1
                        }
                    }
                }else{
                    write-host "Object $object not found (server name)" -ForegroundColor Yellow
                    exit 1
                }
            }else{
                write-host "Object $object not found (server name)" -ForegroundColor Yellow
                exit 1
            }
        }
    }
}else{
    if($objects){
        $sourceIds = @()
        foreach($object in $objects){
            $objectId = getObjectId $object
            if($objectId){
                $sourceIds += $objectId
            }else{
                write-host "Object $object not found" -ForegroundColor Yellow
                exit 1
            }
        }    
    }
}

# get last run id
$runs = api get "protectionRuns?jobId=$($job.id)&numRuns=10"
if($runs){
    $newRunId = $lastRunId = $runs[0].backupRun.jobRunId
}else{
    $newRunId = $lastRunId = 0
}

$finishedStates = @('kCanceled', 'kSuccess', 'kFailure')

# wait for existing job run to finish
if($runs){
    $alertWaiting = $True
    while ($runs[0].backupRun.status -notin $finishedStates){
        if($alertWaiting){
            "waiting for existing job run to finish..."
            $alertWaiting = $false
        }
        sleep 5
        $runs = api get "protectionRuns?jobId=$($job.id)&numRuns=10"
    }    
}

# set local retention
$copyRunTargets = @(
    @{
        "type" = "kLocal";
        "daysToKeep" = $keepLocalFor
    }
)

# add replication target and retention
if ($replicateTo) {
    $remote = api get remoteClusters | Where-Object {$_.name -eq $replicateTo}
    if ($remote) {
        $copyRunTargets = $copyRunTargets + @{
            "daysToKeep" = $keepReplicaFor;
            "replicationTarget" = @{
              "clusterId" = $remote.clusterId;
              "clusterName" = $remote.name
            };
            "type" = "kRemote"
          }
    }
    else {
        Write-Warning "Remote Cluster $replicateTo not found!"
        exit 1
    }
}

# add archival target and retention
if($archiveTo){
    $vault = api get vaults | Where-Object {$_.name -eq $archiveTo}
    if($vault){
        $copyRunTargets = $copyRunTargets + @{
            "archivalTarget" = @{
              "vaultId" = $vault.id;
              "vaultName" = $vault.name;
              "vaultType" = "kCloud"
            };
            "daysToKeep" = $keepArchiveFor;
            "type" = "kArchival"
          }
    }else{
        Write-Warning "Archive target $archiveTo not found!"
        exit 1
    }
}

# Finalize RunProtectionJobParam object
$jobdata = @{
   "runType" = $backupType
   "copyRunTargets" = $copyRunTargets
}

# Add sourceIds if specified
if($objects){
    if(($environment -eq 'kSQL' -and $job.environmentParameters.sqlParameters.backupType -eq 'kSqlVSSFile') -or $environment -eq 'kOracle'){
        $jobdata['runNowParameters'] = $runNowParameters
    }else{
        $jobdata['sourceIds'] = $sourceIds
    }
}

# enable job
if($enable){
    $lastRunTime = (api get "protectionRuns?jobId=$jobId&numRuns=1").backupRun.stats.startTimeUsecs
    while($True -eq (api get protectionJobs/$jobID).isPaused){
        $null = api post protectionJobState/$jobID @{ 'pause'= $false }
        sleep 2
    }
}

# run job
"Running $jobName..."

$null = api post ('protectionJobs/run/' + $jobID) $jobdata

# wait for new job run to appear
$x = 0
while($newRunId -eq $lastRunId){
    sleep 2
    $x += 1
    if($x -ge 30){
        write-host "Timing out waiting for new run" -ForegroundColor Yellow
        exit 1
    }
    $runs = api get "protectionRuns?jobId=$($job.id)&numRuns=10"
    $newRunId = $runs[0].backupRun.jobRunId
}

# wait for job run to finish
if($wait -or $enable){
    $lastProgress = -1
    while ($runs[0].backupRun.status -notin $finishedStates){
        sleep 5
        if($progress){
            $progressMonitor = api get "/progressMonitors?taskPathVec=backup_$($newRunId)_1&includeFinishedTasks=true&excludeSubTasks=false"
            $percentComplete = $progressMonitor.resultGroupVec[0].taskVec[0].progress.percentFinished
            if($percentComplete -gt $lastProgress){
                "{0} percent complete" -f [math]::Round($percentComplete, 0)
                $lastProgress = $percentComplete
            }
        }
        $runs = api get "protectionRuns?jobId=$($job.id)&numRuns=10"
    }
}

# disable job
if($enable){
    while($True -ne (api get protectionJobs/$jobID).isPaused){
        if($lastRunTime -lt (api get "protectionRuns?jobId=$jobId&numRuns=1").backupRun.stats.startTimeUsecs){
            $null = api post protectionJobState/$jobID @{ 'pause'= $true }
        }else{
            sleep 2
        }
    }
}

if($wait -or $enable){
    "Job finished with status: $($runs[0].backupRun.status)"

    if($runs[0].backupRun.status -eq 'kSuccess'){
        Invoke-Command -ComputerName $client -ScriptBlock { delete_files.ps1 -Path "C:\Program Files\Cohesity\user_scripts"}
    }else{
        exit 1
    }
}

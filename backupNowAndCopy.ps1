### usage: ./backupNowAndCopy.ps1 -vip mycluster -username myusername -domain mydomain.net -jobName 'My Job' -archiveTo 'My Target' -keepArchiveFor 5 -replicateTo mycluster2 -keepReplicaFor 5

### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip, # the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username, # username (local or AD)
    [Parameter()][string]$domain = 'local', # local or AD domain
    [Parameter(Mandatory = $True)][string]$jobName, # job to run
    [Parameter()][string]$replicateTo = $null, # optional - remote cluster to replicate to
    [Parameter()][int]$keepReplicaFor = 5, # keep replica for x days
    [Parameter()][string]$archiveTo = $null, # optional - target to archive to
    [Parameter()][int]$keepArchiveFor = 5, # keep archive for x days
    [Parameter()][switch]$enable # enable a disabled job, run it, then disable when done
)

### source the cohesity-api helper code
. 'c:\program files\cohesity\user_scripts\cohesity-api-user-scripts.ps1'

### authenticate
apiauth -vip $vip -username $username -domain $domain

### start logging
$logfile = 'c:\program files\cohesity\user_scripts\scriptlog.txt'
"script started at $(get-date)" | out-file $logfile

### find the jobID
$job = (api get protectionJobs | Where-Object name -ieq $jobName)
if($job){
    $jobID = $job.id

}else{
    Write-Warning "Job $jobName not found!"
    "Job $jobName not found!" | Out-File $logfile -Append
    exit
}

$copyRunTargets = @()

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
         "Remote Cluster $replicateTo not found!" | Out-File $logfile -Append
        exit
    }
}

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
        "Archive target $archiveTo not found!" | Out-File $logfile -Append
        exit
    }
}

### RunProtectionJobParam object
$jobdata = @{
   "runType" = "kRegular"
   "copyRunTargets" = $copyRunTargets
}

"Running $jobName..."

### enable job
if($enable){
    $lastRunTime = (api get "protectionRuns?jobId=$jobId&numRuns=1").backupRun.stats.startTimeUsecs
    while($True -eq (api get protectionJobs/$jobID).isPaused){
        $null = api post protectionJobState/$jobID @{ 'pause'= $false }
        "enabling job" | Out-File $logfile -Append
        sleep 2
    }
    "job enabled" | Out-File $logfile -Append
}

### run job
"Running $jobName..." | Out-File $logfile -Append
$null = api post ('protectionJobs/run/' + $jobID) $jobdata

### disable job
if($enable){
    while($True -ne (api get protectionJobs/$jobID).isPaused){
        "job still enabled" | Out-File $logfile -Append
        if($lastRunTime -lt (api get "protectionRuns?jobId=$jobId&numRuns=1").backupRun.stats.startTimeUsecs){
            "disabling job" | Out-File $logfile -Append
            $null = api post protectionJobState/$jobID @{ 'pause'= $true }
        }else{
            sleep 2
        }
    }
    $pausedAPIresult = (api get protectionJobs/$jobID).isPaused
    "job disabled check: $pausedAPIresult" | Out-File $logfile -Append
}


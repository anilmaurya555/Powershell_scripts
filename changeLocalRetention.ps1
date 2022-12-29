### Usage:
# ./changeLocalRetention.ps1 -vip mycluster `
#                            -username myuser `
#                            -domain mydomain.net `
#                            -jobname 'My Job' `
#                            -snapshotDate '2020-05-01 23:30' `
#                            -daysToKeep 10 `
#                            -force

### process commandline arguments
[CmdletBinding()]
param (
    
    
    [Parameter()][string]$vip,                         # cluster to connect
    [Parameter()][string]$username,                    # user name
    [Parameter()][string]$domain = 'ent.ad.ntrs.com',  # domain name
    [Parameter()][array]$jobname,                      #narrow scope to just the specified jobs (comma separated)
    [Parameter()][switch]$listjobruns,                 # List job runs with existing retentions         
    [Parameter()][DateTime]$after,                     #operate on runs after this date (e.g. '2022-09-01 23:00:00')
    [Parameter()][DateTime]$before,                    #operate on runs before this date (e.g. '2022-10-10 00:00:00')
    [Parameter()][string]$daysToKeep,                  #set retention to X days from original run date
    [Parameter()][ValidateSet("kRegular","kFull","kLog","kSystem","kAll")][string]$backupType = 'kAll',
    [Parameter()][int]$maxRuns = 100000,               #dig back in time for X snapshots. Default is 100000. Increase this value to get further back in time, decrease this parameter if the script reports an error that the response it too large
    [Parameter()][switch]$commit,                      #perform the changes. If omitted, script will run in show/only mode
    [Parameter()][switch]$allowReduction               #if omitted, the script will not reduce the retention of any snapshots
)

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

# authenticate
apiauth -vip $vip -username $username -domain $domain

# filter on job name
$jobs = api get protectionJobs
$joblist = @()
if($jobname.Length -gt 0){
    foreach($j in $jobname){
        $job = $jobs | Where-Object {$_.name -eq $j}
        if($job){
            $joblist += $job
        }else{
            Write-Host "Job $j not found" -ForegroundColor Yellow
            exit
        }
    }
}

function changeRetention($run){
    $startDateUsecs = $run.backupRun.stats.startTimeUsecs
    $startDate = usecsToDate $startDateUsecs
    $newExpireUsecs = [int64](dateToUsecs $startDate.addDays($daysToKeep))
    $newExpireDate = usecsToDate $newExpireUsecs
    $oldExpireUsecs = $run.copyRun[0].expiryTimeUsecs
    if($newExpireUsecs -gt $oldExpireUsecs){
        $daysToChange = [int][math]::Round(($newExpireUsecs - $oldExpireUsecs) / 86400000000)
    }else{
        $daysToChange = -([int][math]::Round(($oldExpireUsecs - $newExpireUsecs) / 86400000000))
    }
    if($daysToChange -eq 0){
        Write-Host "Retention for $($run.jobName) ($($startDate)) to $newExpireDate remains unchanged"
    }else{
        if(!$allowReduction -and $daysToChange -lt 0){
            Write-Host "Would reduce Retention for $($run.jobName) ($($startDate)) to $newExpireDate - skipping"
        }else{
            if($commit){
                $exactRun = api get /backupjobruns?exactMatchStartTimeUsecs=$startDateUsecs`&id=$($run.jobId)
                $jobUid = $exactRun[0].backupJobRuns.protectionRuns[0].backupRun.base.jobUid
                $editRun = @{
                    'jobRuns' = @(
                        @{
                            'jobUid'            = @{
                                'clusterId' = $jobUid.clusterId;
                                'clusterIncarnationId' = $jobUid.clusterIncarnationId;
                                'id' = $jobUid.objectId
                            };
                            'runStartTimeUsecs' = $startDateUsecs;
                            'copyRunTargets'    = @(
                                @{'daysToKeep' = $daysToChange;
                                    'type'     = 'kLocal';
                                }
                            )
                        }
                    )
                }
                write-host "Changing retention for $($run.jobName) ($($startDate)) to $newExpireDate"
                $null = api put protectionRuns $editRun
            }else{
                Write-Host "Would change retention for $($run.jobName) ($($startDate)) to $newExpireDate"
            }
        }
    }
}

if($after){
    $afterUsecs = dateToUsecs $after
}else{
    $afterUsecs = 0
}

if($before){
    $beforeUsecs = dateToUsecs $before
}else{
    $beforeUsecs = dateToUsecs
}

foreach($job in $joblist){
    $runs = api get "protectionRuns?jobId=$($job.id)&numRuns=$maxRuns&runTypes=$backupType&excludeTasks=true&excludeNonRestoreableRuns=true" | Where-Object {$_.backupRun.snapshotsDeleted -ne $True -and
                                                                                                                                                             $_.backupRun.stats.startTimeUsecs -gt $afterUsecs -and                                                                                                                                                     
                                                                                                                                                             $_.backupRun.stats.endTimeUsecs -le $beforeUsecs}
    foreach($run in $runs){

    if ($listjobruns){
          $startDateUsecs = $run.backupRun.stats.startTimeUsecs
          $startDate = usecsToDate $startDateUsecs
          $oldExpireUsecs = $run.copyRun[0].expiryTimeUsecs
          $oldexpiredate = usecsToDate $oldExpireUsecs
                write-host "Existing retention for $($run.jobName) ($($startDate)) to $oldExpireDate"
                     }else{
        changeRetention $run
                           }
    }
}
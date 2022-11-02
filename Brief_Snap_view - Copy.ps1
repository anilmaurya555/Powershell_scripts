
### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$username #username (local or AD)
    
)
# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

# authenticate
apiauth -vip hcohesity03 -username $username -domain corpads.local
$failurnum = 0
$Warningnum = 0
$Successnum = 0
$Runningnum = 0
$Cancelednum = 0

$jobSummary = api get '/backupjobssummary?_includeTenantInfo=true&allUnderHierarchy=true&includeJobsWithoutRun=false&isActive=true&isDeleted=false&numRuns=1000&onlyReturnBasicSummary=true&onlyReturnJobDescription=false'

foreach($job in $jobSummary | Sort-Object -Property { $_.backupJobSummary.jobDescription.name }){
        $startTimeUsecs = $job.backupJobSummary.lastProtectionRun.backupRun.base.startTimeUsecs
        $jobId = $job.backupJobSummary.lastProtectionRun.backupRun.base.jobId
        if($jobId -and $startTimeUsecs){
        #######
            $lastrun = api get "/backupjobruns?allUnderHierarchy=true&exactMatchStartTimeUsecs=$startTimeUsecs&id=$jobId&onlyReturnDataMigrationJobs=false"
           
        ########
            foreach($task in $lastrun.backupJobRuns.protectionRuns[0].backupRun.latestFinishedTasks){
        
                $status = $task.base.publicStatus
                                
                if($status -eq 'kFailure'){
                    $failurnum += 1
                }elseif ($status -eq 'kWarning') {
                    $Warningnum += 1
                }elseif ($status -eq 'kSuccess'){
                    $Successnum += 1
                }elseif ($status -eq 'kRunning'){
                       $Runningnum += 1} 
                 else { 
                 if ($status -eq 'KCanceled')
                             {$Cancelednum += 1 }
                        }

        }

       
}
}
 WRITE-HOST "failure "$failurnum""
        WRITE-HOST "WARNING $Warningnum"
        WRITE-HOST "SUCCESS $Successnum"
        WRITE-HOST "RUNNING $Runningnum"
        WRITE-HOST "CANCELED $Cancelednum"


               
# process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,  # the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username,  # username (local or AD)
    [Parameter()][string]$domain = 'local'  # local or AD domain
    
)
. ./cohesity-api
# authenticate
apiauth -vip $vip -username $username -domain $domain
$finishedStates = @('kCanceled', 'kSuccess', 'kFailure')
$jobs = (api get protectionJobs  | Where-Object { ($_.IsPaused -eq $false -or $_.isPaused -eq $null) -and $_.IsActive -eq $null -and $_.name -notlike "_DELETED_*" })|foreach-object {$_.name}
Add-Content -Path c:\anil\powershell\job_list.txt -Value $jobs

foreach ( $job in $jobs ){ 
                            $newjob = (api get protectionJobs  | Where-Object name -ieq $job)   
                            $jobID = $newjob.id          
                            $runs = api get "protectionRuns?jobId=$jobId&numRuns=1"
                            $newRunId = $runs[0].backupRun.jobRunId      
                                if ($runs[0].backupRun.status -notin $finishedStates){
                                           $null = api post protectionRuns/cancel/$jobID @{ ‘jobRunId’= $newRunId }
                                           write-host "Cohesity job $job cancelled" -ForegroundColor Red
                                                                                        }                       
                                                                                        
                                $null = api post protectionJobState/$jobID @{ 'pause'= $true }

                                                            
                            write-host "Cohesity job $job paused" -ForegroundColor Yellow
                            }
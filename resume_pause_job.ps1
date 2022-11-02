# process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,  # the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username,  # username (local or AD)
    [Parameter()][string]$domain = 'local'  # local or AD domain
    
)
$jobs = get-content c:\anil\powershell\job_list.txt
. ./cohesity-api
# authenticate
apiauth -vip $vip -username $username -domain $domain

     foreach ( $job in $jobs ){ 
                            $newjob = (api get protectionJobs  | Where-Object name -ieq $job)   
                            $jobID = $newjob.id          
                               if ($True -eq (api get protectionJobs/$jobID).isPaused){
                                $null = api post protectionJobState/$jobID @{ 'pause'= $false }
                                write-host "Cohesity job $job Resumed" -ForegroundColor Yellow
                                                              }
                                                               }
                
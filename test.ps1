### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip, #the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username, #username (local or AD)
    [Parameter()][string]$domain = 'local',#local or AD domain
        [Parameter(Mandatory = $True)][string]$smtpServer, #outbound smtp server '192.168.1.95'
    [Parameter()][string]$smtpPort = 25, #outbound smtp port
    [Parameter(Mandatory = $True)][array]$sendTo, #send to address
    [Parameter(Mandatory = $True)][string]$sendFrom #send from address
)

### source the cohesity-api helper code
. ./cohesity-api

### authenticate
apiauth -vip $vip -username $username -domain $domain

### protection runs

$runs = $runs = api get protectionRuns?excludeTasks=true`&numRuns=999999`&startTimeUsecs=$(timeAgo 14 days)
$overallstatus = 'No Jobs Running'
$results = @()
$output = @()
foreach ($run in $runs){
$result = ""|select jobname,starttime,targettype,status # this sets table then later they get value assigned below
    $stillRunning = $false
    $result.jobname = $run.jobName
    $runStartTime = $run.backupRun.stats.startTimeUsecs
    $result.starttime = usecsToDate $runStartTime
    if($run.backupRun.stats.endTimeUsecs -eq $null){
            $overallstatus = $null
        $stillRunning = $True
        $result.targettype = 'Local Snapshot'
        $result.status = $run.backupRun.status.substring(1)
        #"{0,-40} {1,-30} {2,-25} {3}" -f ($jobName, $startTime, $targetType, $status)
                   $results += $result
    }else{
        foreach ($copyRun in $run.copyRun){
            if ($copyRun.target.type -ne 'kLocal'){
                if ($copyRun.stats.endTimeUsecs -eq $null){
                    $overallstatus = $null
                    $stillRunning = $True
                    $result.targettype = $copyRun.target.type.substring(1) 
                    $result.status = $copyRun.status.substring(1)
                   # "{0,-40} {1,-30} {2,-25} {3}" -f ($jobName, $startTime, $targetType, $status)
                   
                    $results += $result
                }
            }
        }
    }
}
$overallstatus
$results |Sort-Object -Property Starttime
$output = $results
### send email report
foreach($toaddr in $sendTo){
    Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Running Jobs on SBCH-DP02AZ"   -body ($output | Out-String)
        }

[CmdletBinding()]

param (

[Parameter(Mandatory = $True)][string]$vip,

[Parameter(Mandatory = $True)][string]$username,

[Parameter()][string]$domain = 'sigi.us.selective.com'

)

### source the cohesity-api helper code
. ./cohesity-api
### authenticate
apiauth -vip $vip -username $username -domain $domain
$24hoursAgo = dateToUsecs (get-date).Adddays(-24)
$now = dateToUsecs (get-date)
$runs = api get protectionRuns?startTimeUsecs=$24hoursAgo 

"{0,-40}{1,-12}{2,-22}{3,-22}{4}" -f 'JobName', 'Status', 'StartTime',  'ExpiryTime', 'DaysToExpiration'

foreach ($run in $runs){

$startTime = usecsToDate ($run.copyRun[0].runStartTimeUsecs)

$expiryTime = usecsToDate ($run.copyRun[0].expiryTimeUsecs)

$daysToExpire = [math]::Round(($run.copyRun[0].expiryTimeUsecs - $now)/(1000000*60*60*24))

"{0,-40}{1,-12}{2,-22}{3,-22}{4}" -f $run.jobName, $run.copyRun[0].status, $startTime, $expiryTime, $daysToExpire

}


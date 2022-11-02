[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][string]$domain = 'local'
)

### source the cohesity-api helper code
. ./cohesity-api

### authenticate
apiauth -vip $vip -username $username -domain $domain

$report = api get reports/protectionSourcesJobsSummary

foreach($obj in $report.protectionSourcesJobsSummary){
    $objName = $obj.protectionSource.name
    $objType = $obj.protectionSource.environment
    $jobName = $obj.jobName
    $numErrors = $obj.numErrors
    $lastGoodUsecs = $obj.lastSuccessfulRunTimeUsecs
    $lastStatus = $obj.lastRunStatus

    if($lastStatus -ne 'kSuccess' -and $numErrors -gt 0){
        
        "{0,-50} {1,-22} {2,-30} {3,-10} {4}" -f $objName, $($objType.subString(1)), $jobName, $numErrors, $(usecsToDate $lastGoodUsecs)
    }
}

<#
SCRIPTNAME: Get-JobRecoveryPoints
AUTHOR: Charles Ahern (cahern@cambridgecomputer.com)
COMPANY: Selective Insurance Company
DATE: April 30, 2019
DESCRIPTION: Gets Expiry Information for Protection Jobs
MODULES: Cohesity.PowerShell
INPUT FILE FORMAT: None
OUTPUT FILE FORMAT: CSV, HTML, E-Mail
CHANGELOG: 
#>
#Functions

function Convert-UsecsToDate
{
    param (
        $usecs
    )
    $unixTime = $usecs/1000000
    [datetime]$origin = '1970-01-01 00:00:00'
    $origin.AddSeconds($unixTime).ToLocalTime()
}

#Setup Session to Cohesity Cluster

#$cCluster = "cohesitypoc.sigi.us.selective.com"
$cCluster = "sbch-dp01br.selective.com"
$storedCred = Unprotect-CmsMessage -Path C:\anil\powershell\CCS\creds.txt -To 046C4BF2BF7326A3FE6BB17A6EE5FA2B0BC41351 | ConvertFrom-Csv
$cUser = $storedCred.domain + "\" + $storedCred.username
$cPwd = ConvertTo-SecureString $storedCred.password -AsPlainText -Force
$cCred = New-Object System.Management.Automation.PSCredential($cUser, $cPwd)
Connect-CohesityCluster -Server $cCluster -Credential $cCred


$outCsv =  "C:\anil\powershell\CCS\Reports\CohesityJobRecoveryPoints-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".csv"
$outHTML = "C:\anil\powershell\CCS\Reports\CohesityJobRecoveryPoints-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".html"
$cPjInfo = @()

$cPj = Get-CohesityProtectionJob

foreach ($j in $cPj)
{
    if([string]::IsNullOrEmpty($j.LastRun.copyRun) -eq $false){$cStatus = $j.LastRun.copyRun[0].Status}
    if([string]::IsNullOrEmpty($j.LastRun.copyRun.stats.startTimeUsecs) -eq $false){$cstart = Convert-CohesityUsecsToDateTime -Usecs $j.LastRun.copyRun.stats.startTimeUsecs}
    if([string]::IsNullOrEmpty($j.LastRun.copyRun.expiryTimeUsecs) -eq $false){$etime = Convert-CohesityUsecsToDateTime -Usecs $j.LastRun.copyRun.expiryTimeUsecs}
    if([string]::IsNullOrEmpty($j.LastRun.copyRun.expiryTimeUsecs) -eq $false){$edays = [math]::Round(($j.LastRun.copyRun.expiryTimeUsecs - (Convert-UsecsToDate -usecs ([DateTime]::Now))) / (1000000*60*60*24))}
    Write-Host "NOW: "  (Convert-UsecsToDate -usecs ([DateTime]::Now))
    $jobInfo = New-Object System.Object
    $jobInfo | Add-Member -MemberType NoteProperty -Name "Id" -Value $j.Id
    $jobInfo | Add-Member -MemberType NoteProperty -Name "Name" -Value $j.Name
    $jobInfo | Add-Member -MemberType NoteProperty -Name "Status" -Value $cStatus
    $jobInfo | Add-Member -MemberType NoteProperty -Name "StartTime" -Value $cstart
    $jobInfo | Add-Member -MemberType NoteProperty -Name "ExpiryTime" -Value $etime
    $jobInfo | Add-Member -MemberType NoteProperty -Name "DaysToExpiration" -Value $edays
    $cPjInfo += $jobInfo
}

$cPjInfo | ft *
$cPjInfo | Export-Csv $outCsv -NoTypeInformation
$cPjInfo | ConvertTo-Html | Add-Content $outHTML
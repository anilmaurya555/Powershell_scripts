<#
SCRIPTNAME: Get-LateRunningJobs.ps1
AUTHOR: Charles Ahern (cahern@cambridgecomputer.com)
COMPANY: Selective Insurance Company
DATE: 3/4/2019
DESCRIPTION: Lists Jobs that are outside the Service Level Agreement (SLA), in other words "late runners"
MODULES: Cohesity.PowerShell
INPUT FILE FORMAT: None
OUTPUT FILE FORMAT: CSV,HTML
CHANGELOG: 
#>

#Functions

function Get-ElapsedTime
{
    param
    (
        $startTime,
        $endTime
    )
    $runTime = (Convert-CohesityUsecsToDateTime -Usecs $endTime) - (Convert-CohesityUsecsToDateTime -Usecs $startTime)
    "{0:HH:mm:ss}" -f ([datetime]$runTime.Ticks)
}

#Setup Session to Cohesity Cluster

if (!(Get-Module -Name Cohesity.PowerShell)){Import-Module Cohesity.PowerShell}
#$cCluster = "cohesitypoc.sigi.us.selective.com"
$cCluster = "sbch-dp01br.selective.com"
$storedCred = Unprotect-CmsMessage -Path C:\anil\powershell\CCS\creds.txt -To 046C4BF2BF7326A3FE6BB17A6EE5FA2B0BC41351 | ConvertFrom-Csv
$cUser = $storedCred.domain + "\" + $storedCred.username
$cPwd = ConvertTo-SecureString $storedCred.password -AsPlainText -Force
$cCred = New-Object System.Management.Automation.PSCredential($cUser, $cPwd)
Connect-CohesityCluster -Server $cCluster -Credential $cCred

$outCsv =  "C:\anil\powershell\CCS\Reports\LateRunningJobs-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".csv"
$outHTML = "C:\anil\powershell\CCS\Reports\LateRunningJobs-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".html"

$lateJobs = @()

$cPj = Get-CohesityProtectionJob | where {($_.LastRun.backupRun.stats.startTimeUsecs -ne $null) -and ($_.LastRun.backupRun.stats.endTimeUsecs -ne $null) -and ((Convert-CohesityUsecsToDateTime -Usecs $_.LastRun.backupRun.stats.endTimeUsecs) - (Convert-CohesityUsecsToDateTime -Usecs $_.LastRun.backupRun.stats.startTimeUsecs)).TotalMinutes -gt $_.FullProtectionSlaTimeMins}

foreach ($j in $cPj)
{
    $lrJobs = Get-CohesityProtectionJobRun -JobId $j.JobId | where {($_.BackupRun.slaViolated -eq $true) -and ((Convert-CohesityUsecsToDateTime -Usecs $_.BackupRun.Stats.StartTimeUsecs).ToShortDateString() -eq (Get-Date).ToShortDateString()) -and (Get-CohesityProtectionJobRun -JobId $j.JobId).Count -gt 2}
    #$lrJobs = $j | Select-Object Id,Name,Description,IsActive,Environment,FullProtectionSlaTimeMins
    $lateJobs += $lrJobs | Select-Object JobId,JobName,IsActive,Status,@{Name='SLAViolated';expression={$_.BackupRun.slaViolated}},@{Name="StartTime";expression={Convert-CohesityUsecsToDateTime -Usecs $_.BackupRun.Stats.StartTimeUsecs}},@{Name="EndTime";expression={Convert-CohesityUsecsToDateTime -Usecs $_.BackupRun.Stats.EndTimeUsecs}},@{Name='ElapsedTime';expression={Get-ElapsedTime -startTime $_.BackupRun.Stats.StartTimeUsecs -endTime $_.BackupRun.Stats.EndTimeUsecs}}
    #$lateJobs += $lrJobs
}

$lateJobs | Export-Csv $outCsv -NoTypeInformation
$lateJobs | ConvertTo-Html | Add-Content $outHTML
$lateJobs | ft -AutoSize
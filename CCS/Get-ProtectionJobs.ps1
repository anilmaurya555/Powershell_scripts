<#
SCRIPTNAME: Get-ProtectionJobs.ps1
AUTHOR: Charles Ahern (cahern@cambridgecomputer.com)
COMPANY: Selective Insurance Company
DATE: 2/26/2019
DESCRIPTION: Get all Protection/Backup Jobs
MODULES: Cohesity.PowerShell
INPUT FILE FORMAT: None
OUTPUT FILE FORMAT: CSV, HTML, Email
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

function Get-Runtime
{
    param
    (
        $rtmicro
    )
    $rtsecs = $rtmicro / 1000000
    $rtTs = [TimeSpan]::FromSeconds($rtsecs)
    "{0:HH:mm:ss}" -f ([datetime]$rtTs.Ticks)
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


$outCsv =  "C:\anil\powershell\CCS\reports\CohesityProtectionJobs-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".csv"
$outHTML = "C:\anil\powershell\CCS\reports\CohesityProtectionJobs-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".html"
$cPjInfo = @()

$cPj = Get-CohesityProtectionJob
foreach ($j in $cPj)
{
    $desc = $j.Description
    if([string]::IsNullOrEmpty($j.AlertingPolicy) -eq $false){$ap = $j.AlertingPolicy[0]}
    $pri = $j.Priority
    $sla = $j.FullProtectionSlaTimeMins
    $isActive = $j.IsActive
    $bstatus = $j.LastRun.backupRun.Status
    if([string]::IsNullOrEmpty($j.LastRun.backupRun.sourceBackupStatus) -eq $false){$bname = $j.LastRun.backupRun.sourceBackupStatus[0].source.Name}
    if([string]::IsNullOrEmpty($j.LastRun.backupRun.stats.startTimeUsecs) -eq $false){$bstart = Convert-CohesityUsecsToDateTime -Usecs $j.LastRun.backupRun.stats.startTimeUsecs}
    if([string]::IsNullOrEmpty($j.LastRun.backupRun.stats.endTimeUsecs) -eq $false){$bend = Convert-CohesityUsecsToDateTime -Usecs $j.LastRun.backupRun.stats.endTimeUsecs}
    if([string]::IsNullOrEmpty($j.LastRun.backupRun.stats.startTimeUsecs) -eq $false -and [string]::IsNullOrEmpty($j.LastRun.backupRun.stats.endTimeUsecs) -eq $false){$belapsed = (Get-ElapsedTime -startTime $j.LastRun.backupRun.stats.startTimeUsecs -endTime $j.LastRun.backupRun.stats.endTimeUsecs)}
    if([string]::IsNullOrEmpty($j.LastRun.backupRun.stats.totalSourceSizeBytes) -eq $false){$btotal = [math]::round($j.LastRun.backupRun.stats.totalSourceSizeBytes[0] / 1Gb, 2)}
    if([string]::IsNullOrEmpty($j.LastRun.backupRun.stats.totalLogicalBackupSizeBytes) -eq $false){$blogical = [math]::round($j.LastRun.backupRun.stats.totalLogicalBackupSizeBytes[0] / 1Gb, 2)}
    if([string]::IsNullOrEmpty($j.LastRun.copyRun) -eq $false){$cStatus = $j.LastRun.copyRun[0].Status}
    $cName = $j.LastRun.copyRun.copySnapshotTasks.source.Name
    if([string]::IsNullOrEmpty($j.LastRun.copyRun.stats.startTimeUsecs) -eq $false){$cstart = Convert-CohesityUsecsToDateTime -Usecs $j.LastRun.copyRun.stats.startTimeUsecs}
    if([string]::IsNullOrEmpty($j.LastRun.copyRun.stats.endTimeUsecs) -eq $false){$cend = Convert-CohesityUsecsToDateTime -Usecs $j.LastRun.copyRun.stats.endTimeUsecs}
    if([string]::IsNullOrEmpty($j.LastRun.copyRun.stats.startTimeUsecs) -eq $false -and [string]::IsNullOrEmpty($j.LastRun.copyRun.stats.endTimeUsecs) -eq $false){$celapsed = (Get-ElapsedTime -startTime $j.LastRun.copyRun.stats.startTimeUsecs -endTime $j.LastRun.copyRun.stats.endTimeUsecs)}
    if([string]::IsNullOrEmpty($j.LastRun.copyRun.stats.logicalSizeBytes) -eq $false){$clogical = [math]::round($j.LastRun.copyRun.stats.logicalSizeBytes[0] / 1Gb, 2)}
    if([string]::IsNullOrEmpty($j.LastRun.copyRun.stats.logicalBytesTransferred) -eq $false){$ctransferred = [math]::round($j.LastRun.copyRun.stats.logicalBytesTransferred[0] / 1Gb, 2)}
    if([string]::IsNullOrEmpty($j.summaryStats.totalLogicalBackupSizeBytes) -eq $false){$stotal = [math]::round($j.summaryStats.totalLogicalBackupSizeBytes[0] / 1Gb, 2)}
    if([string]::IsNullOrEmpty($j.SummaryStats.averageRunTimeUsecs) -eq $false){$saverage = Get-Runtime -rtmicro $j.SummaryStats.averageRunTimeUsecs}
    if([string]::IsNullOrEmpty($j.SummaryStats.fastestRunTimeUsecs) -eq $false){$sfastest = Get-Runtime -rtmicro $j.SummaryStats.fastestRunTimeUsecs}
    if([string]::IsNullOrEmpty($j.SummaryStats.slowestRunTimeUsecs) -eq $false){$sslowest = Get-Runtime -rtmicro $j.SummaryStats.slowestRunTimeUsecs}
    $numsucrun = $j.SummaryStats.numSuccessfulRuns
    if([string]::IsNullOrEmpty($j.SummaryStats.totalLogicalBackupSizeBytes) -eq $false){$stotallog = [math]::round($j.SummaryStats.totalLogicalBackupSizeBytes[0] / 1Gb, 2)}
    
    $jobPolicy = Get-CohesityProtectionPolicy -Ids $j.PolicyId
    
    $jobInfo = New-Object System.Object
    $jobInfo | Add-Member -MemberType NoteProperty -Name "Id" -Value $j.Id
    $jobInfo | Add-Member -MemberType NoteProperty -Name "Name" -Value $j.Name
    $jobInfo | Add-Member -MemberType NoteProperty -Name "Description" -Value $desc
    $jobInfo | Add-Member -MemberType NoteProperty -Name "AlertingPolicy" -Value $ap
    $jobInfo | Add-Member -MemberType NoteProperty -Name "Priority" -Value $pri
    $jobInfo | Add-Member -MemberType NoteProperty -Name "FullProtectionSlaTimeMins" -Value $sla
    $jobInfo | Add-Member -MemberType NoteProperty -Name "IsActive" -Value $isActive
    $jobInfo | Add-Member -MemberType NoteProperty -Name "PolicyName" -Value $jobPolicy.Name
    $jobInfo | Add-Member -MemberType NoteProperty -Name "PolicyDaysToKeep" -Value $jobPolicy.DaysToKeep
    $jobInfo | Add-Member -MemberType NoteProperty -Name "PolicyDescription" -Value $jobPolicy.Description
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastBackupRunStatus" -Value $bstatus
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastBackupRunName" -Value $bname
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastBackupStartTime" -Value $bstart
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastBackupEndTime" -Value $bend
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastBackupElapsedTime" -Value $belapsed
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastBackupTotalSourceSizeGB" -Value $btotal
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastBackupTotalLogicalBackupSizeGB" -Value $blogical
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastCopyRunStatus" -Value $cStatus
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastCopyRunName" -Value $cName
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastCopyStartTime" -Value $cstart
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastCopyEndTime" -Value $cend
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastCopyElapsedTime" -Value $celapsed
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastCopyLogicalGBTransferred" -Value $ctransferred
    $jobInfo | Add-Member -MemberType NoteProperty -Name "LastCopyTotalLogicalSizeGB" -Value $clogical
    $jobInfo | Add-Member -MemberType NoteProperty -Name "TotalLogicalBackupSizeGB" -Value $stotal
    $jobInfo | Add-Member -MemberType NoteProperty -Name "SummaryAverageRuntime" -Value $saverage
    $jobInfo | Add-Member -MemberType NoteProperty -Name "SummaryFastestRunTime" -Value $sfastest
    $jobInfo | Add-Member -MemberType NoteProperty -Name "SummarySlowestRunTime" -Value $sslowest
    $jobInfo | Add-Member -MemberType NoteProperty -Name "SummaryNumSuccessfulRuns" -Value $numsucrun
    $jobInfo | Add-Member -MemberType NoteProperty -Name "SummaryTotalLogicalBackupSizeGB" -Value $stotallog
    #$jobInfo | Add-Member -MemberType NoteProperty -Name "" -Value
    $cPjInfo += $jobInfo
}

if (!(Get-Module -Name Cohesity.PowerShell)){Import-Module Cohesity.PowerShell}

$cPjInfo | Export-Csv $outCsv -NoTypeInformation
$cPjInfo | ConvertTo-Html | Add-Content $outHTML
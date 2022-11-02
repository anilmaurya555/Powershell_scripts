<#
SCRIPTNAME: Get-BackupWindow.ps1
AUTHOR: Charles Ahern (cahern@cambridgecomputer.com)
COMPANY: Selective Insurance Company
DATE: 3/26/2019
DESCRIPTION: Script to get overall length of the backup window
MODULES: Cohesity.PowerShell
INPUT FILE FORMAT: None
OUTPUT FILE FORMAT: CSV, HTML, E-Mail
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

function Get-Token
{
    param
    (
        $cluster,
        $creds,
        $baseUrl
    )
    $aHeader = @{'accept' = 'application/json';
                'content-type' = 'application/json'}
    $aBody = ConvertTo-Json @{"domain" = $creds.domain;
                             "username" = $creds.username;
                             "password" = $creds.password}
    $tokenUrl = $baseUrl + "/public/accessTokens"
    $auth = Invoke-RestMethod -Method Post -Uri $tokenUrl -Headers $aHeader -Body $aBody
    $auth
 }

function Convert-DateToMsecs
 {
    param
    (
        $dateString
    )
    if ($dateString -isnot [datetime]){ $dateString = [datetime] $datestring }
    $msecs = [int64](($dateString) - (Get-Date "1/1/1970")).TotalMilliseconds
    $msecs
 }

 function Convert-MsecsToDate
 {
    param
    (
        $unixTime
    )
    $dt = (([System.DateTimeOffset]::FromUnixTimeMilliseconds($unixTime)).DateTime).ToString("s")
    $dt
 }

function Build-StatsUrl
{
    param
    (
        $baseUrl,
        $schemaName,
        $metricName,
        $entityId,
        $daysAgo,
        $rollupFunction,
        $rollupIntervalSecs
    )
    [int64]$ss = (Convert-DateToMsecs -dateSTring (Get-Date).AddDays(-$daysAgo))
    [int64]$se = (Convert-DateToMsecs -dateSTring (Get-Date))
    $statUrl = $baseUrl + "/public/statistics/timeSeriesStats?startTimeMsecs=$ss&endTimeMsecs=$se&entityId=$($entities.entityId.clusterInstanceIdentifier.id)&schemaName=$schemaName&metricName=$metricName&rollupFunction=$rollupFunction&rollupIntervalSecs=$rollupIntervalSecs"
    $statUrl
}

#Setup Session to Cohesity Cluster
if (!(Get-Module -Name Cohesity.PowerShell)){Import-Module Cohesity.PowerShell}
$cCluster = "sbch-dp04br.selective.com"
$storedCred = Unprotect-CmsMessage -Path c:\anil\powershell\CCS\creds.txt -To 046C4BF2BF7326A3FE6BB17A6EE5FA2B0BC41351 | ConvertFrom-Csv
$cUser = $storedCred.domain + "\" + $storedCred.username
$cPwd = ConvertTo-SecureString $storedCred.password -AsPlainText -Force
$cCred = New-Object System.Management.Automation.PSCredential($cUser, $cPwd)
try
{
    Connect-CohesityCluster -Server $cCluster -Credential $cCred
    $cClusterId = (Get-CohesityClusterConfiguration).Id
    [Net.ServicePointManager]::SecurityProtocol = "Tls12"
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $apiUrl = "https://" + $cCluster + "/irisservices/api/v1"
    $token = Get-Token -cluster $cCluster -creds $storedCred -baseUrl $apiUrl

    $sHeader = @{'accept' = 'application/json';
                 'content-type' = 'application/json';
                 'authorization' = $token.tokenType + ' ' + $token.accessToken}

    $outCsv =  "C:\anil\powershell\ccs\reports\CohesityBackupWindow-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".csv"
    $outHTML = "C:\anil\powershell\ccs\reports\CohesityBackupWindow-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".html"
    $hmOutCsv =  "C:\anil\powershell\ccs\reports\CohesityBackupWindowHeatMap-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".csv"
    $hmOutHTML = "C:\anil\powershell\ccs\reports\CohesityBackupWindowHeatMap-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".html"

    $bWindow = [TimeSpan]"0:00:00:00"
    $jobTime = @()

    $cPj = Get-CohesityProtectionJob
    foreach ($j in $cPj)
    {
        if([string]::IsNullOrEmpty($j.LastRun.backupRun.stats.startTimeUsecs) -eq $false -and [string]::IsNullOrEmpty($j.LastRun.backupRun.stats.endTimeUsecs) -eq $false){$belapsed = (Get-ElapsedTime -startTime $j.LastRun.backupRun.stats.startTimeUsecs -endTime $j.LastRun.backupRun.stats.endTimeUsecs)}
        $bWindow = $bWindow + [TimeSpan]$belapsed
        $bJob = New-Object System.Object
        $bJob | Add-Member -MemberType NoteProperty -Name "JobName" -Value $j.Name
        $bJob | Add-Member -MemberType NoteProperty -Name "ElapsedTime" -Value $belapsed
        #$bJob | Add-Member -MemberType NoteProperty -Name "" -Value 

        $jobTime += $bJob
    }

    #>

    #$sUrl = Build-StatsUrl -baseUrl $apiUrl -schemaName "kClusterStats" -metricName "kMorphedUsageBytes" -entityId $entities.entityId.clusterInstanceIdentifier.id -daysAgo 1 -rollupFunction "rate" -rollupIntervalSecs "120"

    Write-Host "Total Backup Time: $bWindow"

    $jobTime | Export-Csv $outCsv -NoTypeInformation
    $jobTime | ConvertTo-Html | Add-Content $outHTML

    $ioUrl = Build-StatsUrl -baseUrl $apiUrl -schemaName "kBridgeClusterStats" -metricName "kTotalIos" -entityId $entities.entityId.clusterInstanceIdentifier.id -daysAgo 1 -rollupFunction "rate" -rollupIntervalSecs "120"
    $jStats = Invoke-RestMethod -Method Get -Uri $ioUrl -Headers $sHeader -ContentType "application/json" -Verbose
    $totalIOs = $jStats.dataPointVec | Select-Object @{Name="TimeStamp";expression={Convert-MsecsToDate -unixTime $_.timestampMsecs}},@{Name="TotalIO";expression={$_.data.Int64Value}}
    $bwUrl = Build-StatsUrl -baseUrl $apiUrl -schemaName "kBridgeClusterStats" -metricName "kNumBytesWritten" -entityId $entities.entityId.clusterInstanceIdentifier.id -daysAgo 1 -rollupFunction "rate" -rollupIntervalSecs "120"
    $bwStats = Invoke-RestMethod -Method Get -Uri $bwUrl -Headers $sHeader -ContentType "application/json" -Verbose
    $totalBw = $bwStats.dataPointVec | Select-Object @{Name="TimeStamp";expression={Convert-MsecsToDate -unixTime $_.timestampMsecs}},@{Name="BytesWritten";expression={$_.data.Int64Value}}
    
    if ($totalIOs.count -ne $totalBw.Count)
    {
        Write-Warning "Dataset Mismatch"
    }
    else
    {
        ##$totalIOs[0].TimeStamp
        #$totalIOs[0].TotlaIO
        ###$totalBw[0].BytesWritten

        $agStats = @()

        for ($i=1; $i -le $totalIOs.Count; $i++)
        {
            $nstat = New-Object System.Object
            $nstat | Add-Member -MemberType NoteProperty -Name "TimeStamp" -Value $totalIOs[$i].TimeStamp
            $nstat | Add-Member -MemberType NoteProperty -Name "TotalIOs" -Value $totalIOs[$i].TotalIO
            $nstat | Add-Member -MemberType NoteProperty -Name "WriteBandwidthMegabits" -Value ($totalBw[$i].BytesWritten / 125000)
            #$nstat | Add-Member -MemberType NoteProperty -Name "" -Value
            #$nstat | Add-Member -MemberType NoteProperty -Name "" -Value
            $agStats += $nstat
        }

        $agStats | Export-Csv $hmOutCsv -NoTypeInformation
        $agStats | ConvertTo-Html | Add-Content $hmOutHTML
    }
}
catch
{
    Write-Warning ("Error Connecting to Cluster: " + $error[0].Exception.Message)
}




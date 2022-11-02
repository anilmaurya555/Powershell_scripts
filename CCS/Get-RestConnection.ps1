<#
SCRIPTNAME: Get-BackupWindow.ps1
AUTHOR: Charles Ahern (cahern@cambridgecomputer.com)
COMPANY: Selective Insurance Company
DATE: 3/26/2019
DESCRIPTION: Script to get overall length of the backup window
MODULES: 
INPUT FILE FORMAT: None
OUTPUT FILE FORMAT: CSV, HTML, E-Mail
CHANGELOG: 
#>

#Functions

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
    #$aBody
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

function Convert-JsonStatsToObject
{
    param
    (
        $statsJson
    )
    $statBundle = @()
    foreach ($s in $statsJson.dataPointVec)
    {
        $stat = New-Object System.Object
        $stat | Add-Member -MemberType NoteProperty -Name "TimeStamp" -Value $s.dataPointVec.timestampMsecs
        $stat | Add-Member -MemberType NoteProperty -Name "Data" -Value $s.dataPointVec.data.int64Value
        #$stat | Add-Member -MemberType NoteProperty -Name "" -Value
        $statBundle += $stat
    }
    $statBundle
}
 
 [Net.ServicePointManager]::SecurityProtocol = "Tls12"
 [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
 $cred = Unprotect-CmsMessage -Path C:\anil\Powershell\CCS\creds.txt -To 046C4BF2BF7326A3FE6BB17A6EE5FA2B0BC41351 | ConvertFrom-Csv
 $cCluster = "SBCH-DP01BR.sigi.us.selective.com"
 $apiUrl = "https://" + $cCluster + "/irisservices/api/v1"
 $token = Get-Token -cluster $cCluster -creds $cred -baseUrl $apiUrl
 #$token
 $eHeader = @{'accept' = 'application/json';
                 'content-type' = 'application/json';
                 'authorization' = $token.tokenType + ' ' + $token.accessToken}
 $eBody = ConvertTo-Json @{'schemaName' = "kBridgeClusterLogicalStats"}

 $entityUrl = $apiUrl + "/public/statistics/entities?schemaName=kBridgeClusterLogicalStats"
 $entities = Invoke-RestMethod -Method GET -Uri $entityUrl -Headers $eHeader
 $entities.entityId.clusterInstanceIdentifier.id

<#
 $eschemaUrl = $apiUrl + "/public/statistics/entitiesSchema"
 $schemas = Invoke-RestMethod -Method GET -Uri $eschemaUrl -Headers $eHeader
 $schemas | Select-Object name,schemaDescriptiveName | Export-Csv CohesitySchemas.csv
#>
<#
$entitySchemaUrl = $apiUrl + "/public/statistics/entitiesSchema/kMagnetoBackupJobStats"
$entitySchema = Invoke-RestMethod -Method GET -Uri $eschemaUrl -Headers $eHeader
foreach ($es in $entitySchema)
{
    $es.Name
    $es.timeSeriesDescriptorVec | Export-Csv MetricNames-BackupJobStats.csv -Append -NoTypeInformation
}
#$entitySchema
#>

  $sHeader = @{'accept' = 'application/json';
                 'content-type' = 'application/json';
                 'authorization' = $token.tokenType + ' ' + $token.accessToken}
    <#
    $sBody = ConvertTo-Json @{'startTimeMsecs' = $startTime;
                              'endTimeMsecs' = $endTime;
                              'entityId' = $entities.entityId.clusterInstanceIdentifier.id;
                              'schemaName' = "kBridgeClusterStats";
                              'metricName' = 'kWriteIos';
                              'rollupFunction' = 'rate';
                              'rollupIntervalSecs' = '90'}
    #>
    #$sBody
    #$sUrl = $apiUrl + "/public/statistics/timeSeriesStats/"
    #$sUrl = $apiUrl + "/public/statistics/timeSeriesStats?startTimeMsecs=$startTime&endTimeMsecs=$endTime&entityId=$($entities.entityId.clusterInstanceIdentifier.id)&schemaName=kBridgeClusterStats&metricName=kWriteIos&rollupFunction=rate&rollupIntervalSecs=90"
    <#
    $ioUrl = Build-StatsUrl -baseUrl $apiUrl -schemaName "kBridgeClusterStats" -metricName "kTotalIos" -entityId $entities.entityId.clusterInstanceIdentifier.id -daysAgo 1 -rollupFunction "rate" -rollupIntervalSecs "120"
    #$jStats = Invoke-RestMethod -Method Post -Uri $sUrl -Headers $sHeader -Body $sBody -ContentType "application/json" -Verbose | ConvertFrom-Json
    $jStats = Invoke-RestMethod -Method Get -Uri $ioUrl -Headers $sHeader -ContentType "application/json" -Verbose
    $totalIOs = $jStats.dataPointVec | Select-Object @{Name="TimeStamp";expression={Convert-MsecsToDate -unixTime $_.timestampMsecs}},@{Name="TotalIO";expression={$_.data.Int64Value}}
    
    #Convert-JsonStatsToObject -statsJson $jStats.Content.DataPointVec | Export-Csv s.csv -NoTypeInformation

    $bwUrl = Build-StatsUrl -baseUrl $apiUrl -schemaName "kBridgeClusterStats" -metricName "kNumBytesWritten" -entityId $entities.entityId.clusterInstanceIdentifier.id -daysAgo 1 -rollupFunction "rate" -rollupIntervalSecs "120"
    $bwStats = Invoke-RestMethod -Method Get -Uri $bwUrl -Headers $sHeader -ContentType "application/json" -Verbose
    $totalBw = $bwStats.dataPointVec | Select-Object @{Name="TimeStamp";expression={Convert-MsecsToDate -unixTime $_.timestampMsecs}},@{Name="BytesWritten";expression={$_.data.Int64Value}}

 [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
    
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

        $agStats | Export-Csv Heatmap.csv -NoTypeInformation
    }
    #>

    $daysAgo = 1
    $rollupInterval = 120
    
    $cUrl = Build-StatsUrl -baseUrl $apiUrl -schemaName "kBridgeClusterStats" -metricName "kCapacityBytes" -entityId $entities.entityId.clusterInstanceIdentifier.id -daysAgo $daysAgo -rollupFunction "rate" -rollupIntervalSecs $rollupInterval
    $cStats = Invoke-RestMethod -Method Get -Uri $ioUrl -Headers $sHeader -ContentType "application/json" -Verbose
    $cStats.dataPointVec
    $totalCapacity = $cStats.dataPointVec | Select-Object @{Name="TimeStamp";expression={Convert-MsecsToDate -unixTime $_.timestampMsecs}},@{Name="TotalIO";expression={$_.data.Int64Value}}
    
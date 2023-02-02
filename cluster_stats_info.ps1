# process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$username,  # username (local or AD)
    [Parameter()][string]$smtpServer, #outbound smtp server '192.168.1.95'
    [Parameter()][string]$smtpPort = 25, #outbound smtp port
   [Parameter()][array]$sendTo, #send to address
   [Parameter()][string]$sendFrom, #send from address
    [Parameter()][string]$domain = 'ent.ad.ntrs.com'    # local or AD domain
    
)

#################HTML#############
$htmlFileName = "Latest_Clusters_stats.html"
$html = '<html>
<head>
    <style>
                h1 {
            background-color:#b1ffb1;
            }

        p {
            color: #555555;
            font-family:Arial, Helvetica, sans-serif;
        }
        span {
            color: #555555;
            font-family:Arial, Helvetica, sans-serif;
        }
        
        table {
            font-family: Arial, Helvetica, sans-serif;
            color: #333333;
            font-size: 0.75em;
            border-collapse: collapse;
            width: 100%;
        }
        tr {
            border: 1px solid #F1F1F1;
        }
        td,
        th {
            width: 33%;
            text-align: left;
            padding: 6px;
        }
        tr:nth-child(even) {
            background-color: #F1F1F1;
        }
    </style>
</head>
<body>
    
    <div style="margin:15px;">
            <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAARgAAAAoCAMAAAASXRWnAAAC8VBMVE
            WXyTz///+XyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTwJ0VJ2AAAA+nRSTlMAAAECAwQFBgcICQoLDA0ODxARExQVFhcYGRobHB0eHy
            EiIyQlJicoKSorLC0uLzAxMjM0NTY3ODk6Ozw9Pj9AQUNERUZHSElKS0xNTk9QUVJTVFVWV1hZWl
            tcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9foCBgoOEhYaHiImKi4yNjo+QkZKTlJ
            WWl5iZmpucnZ6foKGio6SlpqeoqaqrrK2ur7CxsrO0tba3uLm6u7y9vr/AwcLDxMXGx8jJysvMzc
            7Q0dLT1NXW19jZ2tvc3d7f4OHi4+Xm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+drbbjAAACOZJRE
            FUaIHtWmlcVUUUv6alIgpiEGiZZIpiKu2i4obhUgipmGuihuZWiYmkRBu4JJVappaG5VJRUWrllq
            ZWivtWVuIWllHwShRI51PvnjP33pk7M1d579Gn/j8+zDnnf2b5v3tnu2g1/ocUmvuPRasx83cVu1
            zFB5endtWUCHgoM/+0y1V64sOZcXVlhMDpWXdLM+PmPnmdZTVJeLCPiL6Jd9jT6nfo2y+hH4vE/h
            Fcj6bP6uhcqxvxfYzOdsxOb6gYm39qdrRmE6bBxB2EQWHOXfLBvVvMsIqWdBEYzYvcgWRJ6nS3f5
            +/YSWXEQVeYJPqpXx5XkaaalFuOu22h2E5UVkrIadaAyXFXTwbKh1cw0J3bCgvzFO/CRWtuk3IjP
            lKYK23C7ga3IFCblPwp1HrNvUAyH1W0tRzKlIbk/OmbpbX04uNHGp1/9j6MxMMxUNSYXbqoTJWmF
            t3yCqqHGVLzJK2l8qTtoOzldBqD/C/Ra3hDgOYZKTU2awmpZgVbwG7udWGEvovHYXFHIkuYzHECN
            Pzb0VNy9g8/60KVh5X/QbwtRCajQH//GsQ5k7KCTzqQGprVrwW7HC9GOKQQMhpP30UpWiIM0XYZQ
            gcsYR50Mo9vj73vS9+sOy1Vl6A5S7auXJ53v4Lpr2Trf9LcN0utNsZ/K9Ra4iy++XGE+h3zGGQaV
            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
            8LK0YAAAAASUVORK5CYII=" style="width:180px">
        <p style="margin-top: 15px; margin-bottom: 15px;">
            <span style="font-size:1.3em;"></div>'


$html += '</span>
<span style="font-size:0.75em; text-align: right; padding-top: 8px; padding-right: 2px; float: right;">'+ $date + '</span></p>
 </div>
 </body>
 </html>'

$html += '<table>
                                
                                <p style="margin-top: 15px; margin-bottom: 15px;">Cohesity Clusters Stats: <span style="font-size:1.5em;">' + $vip + '</span></p>               
                                </table>
                                </div>
                                </body>
                                </html>'

                                  
                                  $html += '</span>
                                            </p>
                                            <table>
                                            <tr>
                                                    <th>Cluster Nmae</th>
                                                    <th>SoftwareVersion</th>
                                                    <th>Cluster ID</th>
                                                    <th>Cluster NodeCount</th>
                                                    <th>Healer Status</th>
                                                    <th>ServiceStateSynced</th>
                                                    <th>StoppedServices</th>
                                                    <th>Physical Capacity(Tib)</th>
                                                    <th>Used Capacity(Tib)</th>
                                                    <th>% Used</th>
                                                    <th>HardWare Model</th>
                                                    </tr>'

#################HTML######################################
# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

$dateString = (get-date).ToString('yyyy-MM-dd')
$clusters = ('cohwpcu01','cohsdcu01','chyusnpccp01','chyuswpccp01','chyusnpccp02','chyuswpccp02','chyusnpccp03','chyuswpccp03','chyusnpccp04','chyuswpccp04','chyusnpccp05','chyuswpccp05','chyukpccp01','chyukrccp01','chysgpccp01','chysgrccp01','chymaidcp01','chyididcp01')
#$clusters = ('cohwpcu01','cohsdcu01','chyusnpccp01','chyusnpccp02')
#$clusters = ('chyusnpccp03')

$outfile = "All-clusterInfo-stats.csv"

"Cluster Name, Product Version, Cluster ID,Cluster NodeCount, Healing Status,Service Sync,Stopped Services,Physical Capacity TiB,Used Capacity TiB,Used Percent %,Hardware Model" | Out-File -FilePath $outfile

foreach ($vip in $clusters){

# authenticate
apiauth -vip $vip -username $username -domain $domain -password $password

$cluster = api get cluster?fetchStats=true
$dateString = (get-date).ToString('yyyy-MM-dd')
$TiB = 1024 * 1024 * 1024 * 1024

$clusterId = $cluster.id
### calculate startTimeMsecs
$startTimeMsecs = $(timeAgo 4 days)/1000

# log function
function output($msg, [switch]$warn){
    if($warn){
        Write-Host $msg -ForegroundColor Yellow
    }else{
        Write-Host $msg
    }
    #$msg | Out-File -FilePath $outfile -Append
}

$version = ($cluster.clusterSoftwareVersion -split '_')[0]

$status = api get /nexus/cluster/status
$config = $status.clusterConfig.proto
$nodeStatus = $status.nodeStatus

if($config){
    $chassisList = $config.chassisVec
    $hostName = $status.clusterConfig.proto.clusterPartitionVec[0].hostName
}else{
    $chassisList = (api get -v2 chassis).chassis
    $hostName = (api get clusterPartitions)[0].hostName
}

$physicalCapacity = [math]::round($cluster.stats.usagePerfStats.physicalCapacityBytes / $TiB, 1)
$usedCapacity = [math]::round($cluster.stats.usagePerfStats.totalPhysicalUsageBytes / $TiB, 1)
$usedPct = [int][math]::round(100 * $usedCapacity / $physicalCapacity, 0)

<#
# cluster info
output "`n-------------------------------------------------------"
output ("     Cluster Name: {0}" -f $hostName)
output ("  Product Version: {0}" -f $cluster.clusterSoftwareVersion)
output ("       Cluster ID: {0}" -f $cluster.id)
output ("   Healing Status: {0}" -f $status.healingStatus)
output ("     Service Sync: {0}" -f $status.isServiceStateSynced)
output (" Stopped Services: {0}" -f $status.bulletinState.stoppedServices)
output ("Physical Capacity: {0} TiB" -f $physicalCapacity)
output ("    Used Capacity: {0} TiB" -f $usedCapacity)
output ("     Used Percent: {0}%" -f $usedPct)
output ("-------------------------------------------------------") #>
### collect $days of write throughput stats
<#write-host "Gathering Storage Statistics..." -ForegroundColor Green
$stats = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kMorphedUsageBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400
$stats2 = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kCapacityBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400

                   $clustersdet[$vip]['Installed'] = [math]::Round(($stats2.dataPointVec[-1].data.int64Value)/(1024*1024*1024*1024),2)
                   $clustersdet[$vip]['Used'] = [math]::Round(($stats.dataPointVec[-1].data.int64Value)/(1024*1024*1024*1024),2) #>
"$($hostName),$($cluster.clusterSoftwareVersion),$($cluster.id),$($cluster.nodeCount),$($status.healingStatus),$($status.isServiceStateSynced),$($status.bulletinState.stoppedServices),$($physicalCapacity),$($usedCapacity),$($usedPct),$($cluster.hardwareInfo.hardwareModels)"|Out-File -FilePath $outFile -Append
                           

                           ##############Populate HTML ##############
                                      if ($usedPct -gt 80 ){
                                     $color = 'FF0000'
                                     
                                     }else {
                                               $color = 'FFFFFF'
                                              
                                                      }              
                                                     
                                                     $html += "<tr>         <td>$($hostName)</td>
                                                                            <td>$($cluster.clusterSoftwareVersion)</td>
                                                                            <td>$($cluster.id)</td>
                                                                            <td>$($cluster.nodeCount)</td>
                                                                            <td>$($status.healingStatus)</td>
                                                                            <td>$($status.isServiceStateSynced)</td>
                                                                            <td>$($status.bulletinState.stoppedServices)</td>
                                                                            <td>$($physicalCapacity)</td>
                                                                            <td>$($usedCapacity)</td>
                                                                            <td bgcolor='#$($color)'>$($usedPct)</td>
                                                                            <td>$($cluster.hardwareInfo.hardwareModels)</td>
                                                                        </tr>"

                                                             

                                
                          #####################end HTML #######
                                 }

$html += "
</table>                
</div>
</body>
</html>"

$html | out-file $htmlFileName

"`nOutput saved to $outfile`n"
# send email report
#write-host "sending report to $([string]::Join(", ", $sendTo))"
foreach($toaddr in $sendTo){
   Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Daily Cluster Stats from ALL cluster." -BodyAsHtml $html  -WarningAction SilentlyContinue }
#$html | out-file "$($cluster.name)-objectreport.html"


#copy report to NAS share
$today = get-date
$targetPath = '\\cohwpcu01.ent.ad.ntrs.com\cohesity_reports'
$year = $today.Year.ToString()
$month = $today.Month.ToString()
$date  =  $today.date.ToString('MM-dd') 
# Set Directory Path
$Directory = $targetPath + "\" + $year + "\" + $month + "\" + $date
# Create directory if it doesn't exsist
if (!(Test-Path $Directory))
{
New-Item $directory -type directory
}
# copy File to NAS location
$htmlFileName | Copy-Item -Destination $Directory
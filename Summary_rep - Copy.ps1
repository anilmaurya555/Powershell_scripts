### usage: ./strikeReport.ps1 -vip mycluster -username myusername -domain mydomain.net -sendTo myuser@mydomain.net, anotheruser@mydomain.net -smtpServer 192.168.1.95 -sendFrom backupreport@mydomain.net

### process commandline arguments
[CmdletBinding()]
param (
   # [Parameter(Mandatory = $True)][string]$vip,
    [Parameter(Mandatory = $True)][string]$username,
    #[Parameter()][string]$domain = 'local',
   # [Parameter(Mandatory = $True)][string]$smtpServer, #outbound smtp server '192.168.1.95'
    [Parameter()][string]$smtpPort = 25, #outbound smtp port
   # [Parameter(Mandatory = $True)][array]$sendTo, #send to address
    #[Parameter(Mandatory = $True)][string]$sendFrom, #send from address
    [Parameter()][int]$days = 31,
    [Parameter()][int]$slurp = 500
)

### source the cohesity-api helper code
#. ./cohesity-api
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)
### authenticate


$environments = @('kUnknown', 'kVMware' , 'kHyperV' , 'kSQL' , 'kView' , 'kPuppeteer' , 'kPhysical' , 'kPure' , 'kAzure' , 'kNetapp' , 'kAgent' , 'kGenericNas' , 'kAcropolis' , 'kPhysicalFiles' , 'kIsilon' , 'kKVM' , 'kAWS' , 'kExchange' , 'kHyperVVSS' , 'kOracle' , 'kGCP' , 'kFlashBlade' , 'kAWSNative' , 'kVCD' , 'kO365' , 'kO365Outlook' , 'kHyperFlex' , 'kGCPNative', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown')

write-host "Collecting report data per job..."

### calculate startTimeMsecs
$startTimeMsecs = $(timeAgo 1 days)/1000

$date = (get-date).ToString()

$html = '<html>
<head>
    <style>
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
        bFn+n2lWZQ7q/6id04iW/fI2idFTp4CAOdTWHuNFWZQCf7luMOGr4e9jxCXu1WBxw3Ja03XJs8FG
        ZFdBcbusY2NRKM2k9mD32oXwKLxIGRTMWsMFpon14PAGKTynX/9z17ot27Z23KxyeMLLT1bw6hHT
        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
        8LK0YAAAAASUVORK5CYII=" style="width:180px">
        <p style="margin-top: 15px; margin-bottom: 15px;">
            <span style="font-size:1.3em;">'



$clusters = ('hcohesity01')
$domain = 'corpads.local'

$html += '</table>
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:2em;">Backup Summary Reports From ALL cluster</span></p>               
</div>
</body>
</html>
'

foreach ( $vip in $clusters) {
apiauth -vip $vip -username $username -domain corpads.local

$cluster = api get cluster
$clusterInfo = api get cluster?fetchStats=true
$clusterId = $clusterInfo.id

$title = "Backup Summary Report ($($cluster.name))"
$jobs = api get "protectionJobs?isDeleted=false&isActive=true"
#$html += $title
$html += '<table align="center" border="1" cellpadding="4" cellspacing="0" style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;"> <tbody><tr><td colspan="21" align="LEFT" valign="TOP" bgcolor="#000080"><font size="+1" color="#FFFFFF">'+$title+'</font></td></tr><tr bgcolor="#FFFFFF">'

#$html += '</span>
#<span style="font-size:1em; text-align: right; padding-top: 8px; padding-right: 2px; float: right;">'
#$html += $date
#$html += '</span>
#</p>
#<table>
#<tr>
  #  <th>Object Name</th>
  #  <th>DB Name</th>
  #  <th>Object Type</th>
   # <th>Job Name</th>
    #<th>Failure Count</th>
    #<th>Last Good Backup</th>
    #<th>Last Error</th>
#</tr>'

$errorsRecorded = 0
$errorCount = @{}
$latestError = @{}
$skip = @()
$jobEntry = @{}
$appErrors = @{}
$objErrors = @{}
$allObjects = @()
$totalObjects = 0
$totalFailedObjects = 0

foreach($job in $jobs | Sort-Object -Property name){
    $objType = $job.environment
    #"$($job.name)"
    # get all runs for the job
    $runs = api get "/backupjobruns?id=$($job.id)&startTimeUsecs=$(timeAgo $days days)&allUnderHierarchy=true&excludeTasks=true&numRuns=99999"
    $runCount = $runs.backupJobRuns.protectionRuns.count -1
    $runNum = 0
    $thisSlurp = $slurp
    # slurp detailed job runs
    while($runCount -gt 0){
        if($runCount -lt $thisSlurp){
            $thisSlurp = $runCount
        }
        $startTimeUsecs = $runs.backupJobRuns.protectionRuns[$runNum + $thisSlurp].backupRun.base.startTimeUsecs
        $endTimeUsecs = $($runs.backupJobRuns.protectionRuns[$runNum].backupRun.base.endTimeUsecs)
        if($endTimeUsecs -ge 0){
            $theseRuns = api get "/backupjobruns?startTimeUsecs=$startTimeUsecs&endTimeUsecs=$endTimeUsecs&numRuns=$slurp&id=$($job.id)"
        }else{
            $theseRuns = api get "/backupjobruns?startTimeUsecs=$startTimeUsecs&numRuns=$slurp&id=$($job.id)"
        }
        foreach($protectionRun in $theseRuns.backupJobRuns.protectionRuns){
            $runStartTimeUsecs = $protectionRun.backupRun.base.startTimeUsecs
            foreach($task in $protectionRun.backupRun.latestFinishedTasks){
                $objName = $task.base.sources[0].source.displayName
                # add object to allObjects list
                if($objName.ToString().ToLower() -notin $allObjects){
                    $allObjects += $objName.ToString().ToLower()
                    $totalObjects += 1
                }
                $objStatus = $task.base.publicStatus
                # record failure
                if($objName -notin $skip -and $objStatus -eq 'kFailure'){
                    $errorsRecorded += 1
                    if($objName -notin $errorCount.Keys){
                        # record most recent error
                        $totalFailedObjects +=1
                        $errorCount[$objName] = 1
                        $latestError[$objName] = $task.base.error.errorMsg
                        $appHtml = ''
                        if($task.psobject.properties['appEntityStateVec']){
                            # record per-DB failures
                            foreach($app in $task.appEntityStateVec){
                                $totalObjects += 1
                                if($app.publicStatus -ne 'kSuccess'){
                                    $totalFailedObjects += 1
                                    $appHtml += "<tr>
                                        <td></td>
                                        <td>$($app.appEntity.displayName)</td>
                                        <td>$($environments[$app.appEntity.type].subString(1))</td>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                        <td>$($app.error.errorMsg)</td>
                                    </tr>"
                                }
                            }
                        }
                        $appErrors[$objName] = $appHtml
                    }else{
                        $errorCount[$objName] += 1
                    }
                    # populate html record
                    $jobId = $job.id
                    $jobName = $job.name
                    $jobUrl = "https://$vip/protection/job/$jobId/details"
                    $jobEntry[$objName] = "<a href=$jobUrl>$jobName</a>"
                    $objErrors[$objName] = "<tr>
                        <td>$objName</td>
                        <td>-</td>
                        <td>$($objType.subString(1))</td>
                        <td>$($jobEntry[$objName])</td>
                        <td>$($errorCount[$objName])+</td>
                        <td>More than $days days ago</td>
                        <td>$($latestError[$objName])</td>
                    </tr>"
                }else{
                    if($objName -notin $skip){
                        # last good backup
                        $skip += $objName
                        $objErrors[$objName] = "<tr>
                            <td>$objName</td>
                            <td>-</td>
                            <td>$($objType.subString(1))</td>
                            <td>$($jobEntry[$objName])</td>
                            <td>$($errorCount[$objName])</td>
                            <td>$(usecsToDate $runStartTimeUsecs)</td>
                            <td>$($latestError[$objName])</td>
                        </tr>"
                    }
                }
            }
        }
        $runNum += $thisSlurp
        $runCount -= $thisSlurp
    }
    
}

#foreach($objName in ($errorCount.Keys | Sort-Object)){
   #$html += $objErrors[$objName]
    #if($objName -in $appErrors.Keys){
       # $html += $appErrors[$objName]
   # }
#}
############jobs#############
$percentFailed = (($totalObjects-$totalFailedObjects)/$totalObjects).ToString("P")
$html += '</table>
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">Number of errors reported: ' + $totalFailedObjects + '</span></p>               
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">' + $totalFailedObjects + ' protected objects failed out of ' + $totalObjects + ' total objects (' + $percentFailed + ' success rate)</span></p>               
</div>
</body>
</html>'
##############3jobs###########
####################stats#########################3
$consumption = 0
$totalsize = 0
$logical = 0
$totallogical = 0
$alltotal = 0
$alltotallogical = 0
$clusteractualsize = 0
$GB = (1024*1024*1024)
$stats2 = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kCapacityBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400
$stat2Consumed = 0
		foreach ($stat in $stats2.dataPointVec){
		$consumed = $stat.data.int64Value/$GB
		$stat2Consumed =  [math]::Round($consumed)
	}
	
    Write-Host "  Local Jobs..."
foreach($job in $jobs | Sort-Object -Property name){
    if($job.policyId.split(':')[0] -eq $cluster.id){
        $stats = api get "stats/consumers?consumerType=kProtectionRuns&consumerIdList=$($job.id)"
        if($stats.statsList){
            $name = $job.name
            $environment = $job.environment.subString(1)
            $location = 'Local'
        $logicalBytes = $stats.statsList[0].stats.totalLogicalUsageBytes
        $dataIn = $stats.statsList[0].stats.dataInBytes
        $dataInAfterDedup = $stats.statsList[0].stats.dataInBytesAfterDedup
        $dataWritten = $stats.statsList[0].stats.dataWrittenBytes
        $consumedBytes = $stats.statsList[0].stats.storageConsumedBytes
        if($dataInAfterDedup -gt 0 -and $dataWritten -gt 0){
            $dedup = [math]::Round($dataIn/$dataInAfterDedup,1)
            $compression = [math]::Round($dataInAfterDedup/$dataWritten,1)
        }else{
            $dedup = 0
            $compression = 0
        }
        if($consumedBytes -gt 0){
            $reduction = [math]::Round($logicalBytes / $consumedBytes, 1)
        }else{
            $reduction = 0
        }
        $consumption = [math]::Round($consumedBytes / (1024 * 1024 * 1024), 2)
        $totalsize += $consumption
        $logical = [math]::Round($logicalBytes / (1024 * 1024 * 1024), 2)
        $totallogical += $logical
        $dataInGiB = [math]::Round($dataIn / (1024 * 1024 * 1024), 2)
        #Write-Host ("{0,30}: {1,11:f2} {2}" -f $name, $consumption, 'GiB')
        
              
            
        }
    }
}

Write-Host "  Unprotected Views..."
$views = api get views?allUnderHierarchy=true
foreach($view in $views.views | Sort-Object -Property name | Where-Object viewProtection -eq $null){
    $stats = api get "stats/consumers?consumerType=kViews&consumerIdList=$($view.viewId)"
    if($stats.statsList){
                    $name = $view.name
            $environment = 'View'
            $location = 'Local'
                $logicalBytes = $stats.statsList[0].stats.totalLogicalUsageBytes
        $dataIn = $stats.statsList[0].stats.dataInBytes
        $dataInAfterDedup = $stats.statsList[0].stats.dataInBytesAfterDedup
        $dataWritten = $stats.statsList[0].stats.dataWrittenBytes
        $consumedBytes = $stats.statsList[0].stats.storageConsumedBytes
        if($dataInAfterDedup -gt 0 -and $dataWritten -gt 0){
            $dedup = [math]::Round($dataIn/$dataInAfterDedup,1)
            $compression = [math]::Round($dataInAfterDedup/$dataWritten,1)
        }else{
            $dedup = 0
            $compression = 0
        }
        if($consumedBytes -gt 0){
            $reduction = [math]::Round($logicalBytes / $consumedBytes, 1)
        }else{
            $reduction = 0
        }
        $consumption = [math]::Round($consumedBytes / (1024 * 1024 * 1024), 2)
        $totalsize += $consumption
        $logical = [math]::Round($logicalBytes / (1024 * 1024 * 1024), 2)
        $totallogical += $logical
        $dataInGiB = [math]::Round($dataIn / (1024 * 1024 * 1024), 2)
        #Write-Host ("{0,30}: {1,11:f2} {2}" -f $name, $consumption, 'GiB')
                  
    }
}

Write-Host "  Replicated Jobs..."
foreach($job in $jobs | Sort-Object -Property name){
    if($job.policyId.split(':')[0] -ne $cluster.id){
        $stats = api get "stats/consumers?consumerType=kReplicationRuns&consumerIdList=$($job.id)"
        if($stats.statsList){
                  $name = $job.name
            $environment = $job.environment.subString(1)
            $location = 'Replicated'
                            $logicalBytes = $stats.statsList[0].stats.totalLogicalUsageBytes
        $dataIn = $stats.statsList[0].stats.dataInBytes
        $dataInAfterDedup = $stats.statsList[0].stats.dataInBytesAfterDedup
        $dataWritten = $stats.statsList[0].stats.dataWrittenBytes
        $consumedBytes = $stats.statsList[0].stats.storageConsumedBytes
        if($dataInAfterDedup -gt 0 -and $dataWritten -gt 0){
            $dedup = [math]::Round($dataIn/$dataInAfterDedup,1)
            $compression = [math]::Round($dataInAfterDedup/$dataWritten,1)
        }else{
            $dedup = 0
            $compression = 0
        }
        if($consumedBytes -gt 0){
            $reduction = [math]::Round($logicalBytes / $consumedBytes, 1)
        }else{
            $reduction = 0
        }
        $consumption = [math]::Round($consumedBytes / (1024 * 1024 * 1024), 2)
        $totalsize += $consumption
        $logical = [math]::Round($logicalBytes / (1024 * 1024 * 1024), 2)
        $totallogical += $logical
        $dataInGiB = [math]::Round($dataIn / (1024 * 1024 * 1024), 2)
        #Write-Host ("{0,30}: {1,11:f2} {2}" -f $name, $consumption, 'GiB')
        
        }
    }
}


    ######################stats########################33
##########stats#######3
$clusteractualsize = [math]::Round($stat2Consumed  / (1024), 2)
$alltotal =  [math]::Round($totalsize / (1024), 2)
$alltotallogical = [math]::Round($totallogical / (1024), 2)
$html += '</table> 
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">Cluster actual physical size  in TB: ' + $clusteractualsize + '</span></p>
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">Total Backup size  in TB: ' + $alltotallogical + '</span></p>
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">Total physical space consumed on Cohesity Cluster in TB: ' + $alltotal + '</span></p>
                           
</div>
</body>
</html>'
################stats#########
################change rate ##########3
$html += '</table> 
 <p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">Server having change rate more than 10%</span></p>
 </div>
</body>
</html>'
                                    $html += '</span>
                                                <span style="font-size:1em; ">'
                                                $html += '</span>
                                                </p>
                                                <table>
                                                        <tr>
                                                          <th>Server Name</th>
                                                            <th>Percentage change</th>
                                                        </tr>'
            $jobSummary = api get '/backupjobssummary?_includeTenantInfo=true&allUnderHierarchy=true&includeJobsWithoutRun=false&isActive=true&isDeleted=false&numRuns=1000&onlyReturnBasicSummary=true&onlyReturnJobDescription=false'
            $found = $false
            foreach($job in $jobSummary | Sort-Object -Property { $_.backupJobSummary.jobDescription.name }){

	                    $startTimeUsecs = $job.backupJobSummary.lastProtectionRun.backupRun.base.startTimeUsecs
                        $endTimeUsecs = $job.backupJobSummary.lastProtectionRun.backupRun.base.endTimeUsecs
                        $jobId = $job.backupJobSummary.lastProtectionRun.backupRun.base.jobId

                        $lastrun = api get "/backupjobruns?allUnderHierarchy=true&exactMatchStartTimeUsecs=$startTimeUsecs&id=$jobId&onlyReturnDataMigrationJobs=false"
                             foreach($task in $lastrun.backupJobRuns.protectionRuns[0].backupRun.latestFinishedTasks){
                            $entity = $task.base.sources[0].source.displayName
                            $dataWritten = $task.base.totalPhysicalBackupSizeBytes
                             $logicalSize = $task.base.totalLogicalBackupSizeBytes
                                 if ( $logicalSize -gt 0) {
                                 $changeRate = $dataWritten / $logicalSize
        	                     $changeRatePct = [math]::Round(100 * $changeRate, 1)
                                        }
                               
                              
                               
                                if ( $changeRatePct -gt 10 ) {
                                            $headings = @('Server','Percent')
                                                                                       
                                                            $html += '</tr>'
                                                            $nowrap = 'nowrap'
                                                                    $html += ("<td>{0}</td>
                                                                                <td>{1}</td>
                                                                                </tr>" -f $entity, $changeRatePct)
                                                                                $found = $True
                                                                                

                                             } 
                                             


        }
}
                                               if ($found -eq $false ) {
                                                    
                                                    $html += '</table> 
                                                    <p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;"> No client found with Percent change greater than 10</span></p>
                                                    </div>
                                                    </body>
                                                    </html>'  
                                                    }                                
#################3change rate ##########
}
$fileName = "./strikeReport-$($cluster.name).html"
$html | out-file $fileName

#write-host "sending report to $([string]::Join(", ", $sendTo))"
### send email report
#foreach($toaddr in $sendTo){
 #   Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Backup Strike Report" -BodyAsHtml $html -Attachments $fileName -WarningAction SilentlyContinue
  #  }
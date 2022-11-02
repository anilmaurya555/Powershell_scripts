### usage: ./strikeReport.ps1 -vip mycluster -username myusername -domain mydomain.net -sendTo myuser@mydomain.net, anotheruser@mydomain.net -smtpServer 192.168.1.95 -sendFrom backupreport@mydomain.net

### process commandline arguments
[CmdletBinding()]
param (
   # [Parameter(Mandatory = $True)][string]$vip,
    [Parameter(Mandatory = $True)][string]$username,
    #[Parameter()][string]$domain = 'local',
   [Parameter()][string]$smtpServer, #outbound smtp server '192.168.1.95'
   [Parameter()][string]$smtpPort = 25, #outbound smtp port
    [Parameter()][array]$sendTo, #send to address
   [Parameter()][string]$sendFrom, #send from address
    [Parameter()][int]$days = 2,
    [Parameter()][int]$slurp = 500
)

### source the cohesity-api helper code
#. ./cohesity-api
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)
### authenticate

$environments = @('env_name', 'kVMware', 'kHyperV', 'kSQL', 'kView', 'kPuppeteer', 'kPhysical', 'kPure', 'kAzure', 'kNetapp', 'kAgent', 'kGenericNas', 'kAcropolis', 'kPhysicalFiles', 'kIsilon', 'kKVM', 'kAWS', 'kExchange', 'kHyperVVSS', 'kOracle', 'kGCP', 'kFlashBlade', 'kAWSNative', 'kVCD', 'kO365', 'kO365Outlook', 'kHyperFlex', 'kGCPNative', 'kAzureNative', 'kAD', 'kAWSSnapshotManager', 'kGPFS', 'kRDSSnapshotManager', 'kKubernetes', 'kNimble', 'kAzureSnapshotManager', 'kElastifile', 'kCassandra', 'kMongoDB', 'kHBase', 'kHive', 'kHdfs', 'kCouchbase')
#$environments = @('kUnknown', 'kVMware' , 'kHyperV' , 'kSQL' , 'kView' , 'kPuppeteer' , 'kPhysical' , 'kPure' , 'kAzure' , 'kNetapp' , 'kAgent' , 'kGenericNas' , 'kAcropolis' , 'kPhysicalFiles' , 'kIsilon' , 'kKVM' , 'kAWS' , 'kExchange' , 'kHyperVVSS' , 'kOracle' , 'kGCP' , 'kFlashBlade' , 'kAWSNative' , 'kVCD' , 'kO365' , 'kO365Outlook' , 'kHyperFlex' , 'kGCPNative', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown')

write-host "Collecting report data per job..."

### calculate startTimeMsecs
$startTimeMsecs = $(timeAgo 1 days)/1000

$date = (get-date).ToString()

$html = '<html>
<head>
    <style>
        h1 {
            background-color:#0000ff;
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
            text-align: left;
            padding: 6px;
        }
        tr:nth-child(even) {
            background-color: #F1F1F1;
        }
    </style>
</head>
<body>
    
    </div>'



$clusters = ('hcohesity01','hcohesity03','hcohesity04','hcohesity05')
#$clusters = ('hcohesity01')
$domain = 'corpads.local'

$html += '<div style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:2em;"><font face="Tahoma" size="+2" color="D35400"> 
<left>Backup Summary Reports From ALL cluster<br>
</div>'

foreach ( $vip in $clusters) {
apiauth -vip $vip -username $username -domain corpads.local

$cluster = api get cluster
$clusterInfo = api get cluster?fetchStats=true
$clusterId = $clusterInfo.id

$title = "Backup Summary Report ($($cluster.name))"

$jobs = api get "protectionJobs?isDeleted=false&isActive=true"
$html += '<h1><div style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;"><font face="Tahoma" size="+1" color="#FFFFFF"> 
<left>'+ $title +'<br></h1>
</div>'

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
    if($objType -eq 'kSql' -or $objType -eq 'kOracle'){
        $runClasses = @('runTypes=kRegular&runTypes=kFull&runTypes=kSystem', 'runTypes=kLog')
    }else{
        $runClasses = @('runTypes=kAll')
    }
    #"$($job.name)"
    # get all runs for the job
    foreach($runClass in $runClasses){
    $runs = api get "/backupjobruns?id=$($job.id)&startTimeUsecs=$(timeAgo $days days)&allUnderHierarchy=true&excludeTasks=true&numRuns=99999&$($runClass)"
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
}

#foreach($objName in ($errorCount.Keys | Sort-Object)){
   #$html += $objErrors[$objName]
    #if($objName -in $appErrors.Keys){
       # $html += $appErrors[$objName]
   # }
#}
############jobs#############
$percentFailed = (($totalObjects-$totalFailedObjects)/$totalObjects).ToString("P")
$percentfailedr = (($totalObjects-$totalFailedObjects)/$totalObjects)

if ( $percentFailedr -lt 1 ) {
$html += '</table>
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">Number of errors reported: ' + $totalFailedObjects + '</span></p>               
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">' + $totalFailedObjects + ' protected objects failed out of ' + $totalObjects + ' total objects <span style="color: #FF0000">(' + $percentFailed + ' success rate.)</span></span></p>               
</div>
</body>
</html>'
        } else {
        $html += '</table>
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">Number of errors reported: ' + $totalFailedObjects + '</span></p>               
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">' + $totalFailedObjects + ' protected objects failed out of ' + $totalObjects + ' total objects <span style="color: #0000FF">(' + $percentFailed + ' success rate.)</span></span></p>               
</div>
</body>
</html>'
}
##############3jobs###########
####################stats#########################3
$jobs = api get protectionJobs?allUnderHierarchy=true
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




#$html += '</table> 
#<p style="margin-top: 15px; margin-bottom: 15px;"><table border="1" width="500"><span style="font-size:1em;">Server having Data change rate more than 10%</span></p>
  
 #</div>
#</body>
#</html>'
                                    $html += '</span>
                                                <span style="font-size:1em ">'
                                                $html += '</span>

                                                </p>
                                                <table><table bgcolor="#ffffcc" style="width:30%" bordercolor="maroon" cellspacing="5" cellpadding="3" border="3" bordercolor="#c86260">
                                                        
                                                        <tr>
                                                            
                                                            <th bgcolor="#F5CBA7" width="27%">Servers having data change rate more than 10%</th>
                                                            <th bgcolor="#D35400" width="3%">Percentage change</th>
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
                                                                    $html += ("<td> {0}</td>
                                                                                <td>{1}</td>
                                                                                </tr>" -f $entity, $changeRatePct)
                                                                                $found = $True
                                                                                

                                             } 
                                             


        }
}
                                               if ($found -eq $false ) {
                                                    
                                                    $html += '</table> 
                                                    <p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;"> NO Server found with Data change rate more than 10%</span></p>
                                                    </div>
                                                    </body>
                                                    </html>'  
                                                    }
                                                      
#################3change rate ##########
    ######################stats########################33
##########stats#######3
$clusteractualsize = [math]::Round($stat2Consumed  / (1024), 2)
$alltotal =  [math]::Round($totalsize / (1024), 2)
$alltotallogical = [math]::Round($totallogical / (1024), 2)
$percentused = ($alltotal/$clusteractualsize).ToString("P")
$html += '</table> 
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">Cluster actual physical size  in TB: ' + $clusteractualsize + '</span></p>
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">Total Logical Backup size  in TB: ' + $alltotallogical + '</span></p>
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;">Total physical space consumed on Cohesity Cluster in TB: ' + $alltotal + '<span style="color: #0000FF">(' + $percentused +' Overall usage. )</span></span></p>
                           
</div>
</body>
</html>'
################stats#########
################change rate ##########3
}
$fileName = "./Cohesity_summary_report.html"
$html | out-file $fileName

#write-host "sending report to $([string]::Join(", ", $sendTo))"
#end email report
foreach($toaddr in $sendTo){
    Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Cohesity enviornment Summary Report" -BodyAsHtml $html -Attachments $fileName -WarningAction SilentlyContinue
    }
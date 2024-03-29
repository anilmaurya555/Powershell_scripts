﻿### usage: ./strikeReport.ps1 -vip mycluster -username myusername -domain mydomain.net -sendTo myuser@mydomain.net, anotheruser@mydomain.net -smtpServer 192.168.1.95 -sendFrom backupreport@mydomain.net

### process commandline arguments
[CmdletBinding()]
param (
    
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][string]$smtpServer, #outbound smtp server '192.168.1.95'
    [Parameter()][string]$smtpPort = 25, #outbound smtp port
    [Parameter()][array]$sendTo, #send to address
    [Parameter()][string]$sendFrom, #send from address
    [Parameter()][int]$days = 2,
    [Parameter()][int]$slurp = 500
    
)

### source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

$title = "Cohesity Clients Summary Report as of "
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
            border: 3px solid maroon;
            font-size: 0.75em;
            border-collapse: collapse;
             width:25%;
		 margin:0 auto;
            
        }
        tr {
            border: 1px solid #F1F1F1;
        }
        td {
            border:2px solid blue;
		   padding:10px;
            text-align: left;
            background-color: #EAFAF1;
            
        }
        th {
            border:2px solid blue;
		   padding:10px;
            text-align: left;
            font-size:1em;
            background-color: #FFC300;
            
        }
        tr:nth-child(even) {
            background-color: #FADBD8;
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

$html += $title
$html += '</span>
<span style="font-size:1em; text-align: right; padding-top: 300px; padding-right: 100px; float: center;">'
$html += $date
$html += '</span>
</p>
<table>
<tr>
    <th>Cluster Name</th>
    <th>Total Clients</th>
    <th>Failed clients</th>
    <th>Suceess Clients</th>
    <th>Completed with Exception</th>
    <th>Running Clients</th>
    <th>Canceled Clients</th>
    <th>Overall success</th>
</tr>'

$clusters = ("Hcohesity01","Hcohesity03","Hcohesity04","Hcohesity05")
#$clusters = ("Hcohesity03")
### authenticate
foreach ( $clustername in $clusters){
apiauth -vip $clustername -username $username -domain corpads.local

# $environments = @('kUnknown', 'kVMware' , 'kHyperV' , 'kSQL' , 'kView' , 'kPuppeteer' , 'kPhysical' , 'kPure' , 'kAzure' , 'kNetapp' , 'kAgent' , 'kGenericNas' , 'kAcropolis' , 'kPhysicalFiles' , 'kIsilon' , 'kKVM' , 'kAWS' , 'kExchange' , 'kHyperVVSS' , 'kOracle' , 'kGCP' , 'kFlashBlade' , 'kAWSNative' , 'kVCD' , 'kO365' , 'kO365Outlook' , 'kHyperFlex' , 'kGCPNative', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown')
$environments = @('env_name', 'kVMware', 'kHyperV', 'kSQL', 'kView', 'kPuppeteer', 'kPhysical', 'kPure', 'kAzure', 'kNetapp', 'kAgent', 'kGenericNas', 'kAcropolis', 'kPhysicalFiles', 'kIsilon', 'kKVM', 'kAWS', 'kExchange', 'kHyperVVSS', 'kOracle', 'kGCP', 'kFlashBlade', 'kAWSNative', 'kVCD', 'kO365', 'kO365Outlook', 'kHyperFlex', 'kGCPNative', 'kAzureNative', 'kAD', 'kAWSSnapshotManager', 'kGPFS', 'kRDSSnapshotManager', 'kKubernetes', 'kNimble', 'kAzureSnapshotManager', 'kElastifile', 'kCassandra', 'kMongoDB', 'kHBase', 'kHive', 'kHdfs', 'kCouchbase')

write-host "Collecting report data per job..."

$jobs = api get "protectionJobs?isDeleted=false&isActive=true"
$cluster = api get cluster


$errorsRecorded = 0

$errorCount = @{}
$latestError = @{}
$skip = @()
$jobEntry = @{}
$appErrors = @{}
$objErrors = @{}
$allObjects = @()
$totalObjects = 0
$Successnum = 0
$Warningnum = 0
$Runningnum = 0
$Cancelednum = 0
$totalFailedObjects = 0

foreach($job in $jobs | Sort-Object -Property name){
    $objType = $job.environment
    if($objType -eq 'kSql' -or $objType -eq 'kOracle'){
        $runClasses = @('runTypes=kRegular&runTypes=kFull&runTypes=kSystem', 'runTypes=kLog')
    }else{
        $runClasses = @('runTypes=kAll')
    }
    foreach($runClass in $runClasses){
        
        # get all runs for the job
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
                        if ($task.base.publicStatus -eq 'kSuccess'){ $Successnum += 1}
                        if ($task.base.publicStatus -eq 'kWarning') {$Warningnum += 1}
                        if ($task.base.publicStatus -eq 'kRunning'){ $Runningnum += 1} 
                        if ($task.base.publicStatus -eq 'KCanceled') {$Cancelednum += 1 }
                    }
                    $objStatus = $task.base.publicStatus
                    
                    # record failure
                    if($objName -notin $skip -and $objStatus -eq 'kFailure'){
                        
                            if($objName -notin $errorCount.Keys){
                            $totalFailedObjects +=1
                            $errorCount[$objName] = 1
                            if($task.psobject.properties['appEntityStateVec']){
                                # record per-DB failures
                                foreach($app in $task.appEntityStateVec){
                                    $totalObjects += 1
                                    
                                    if($app.publicStatus -ne 'kSuccess'){
                                        $totalFailedObjects += 1
                                        
                                    }
                                }
                            }
                            }else { $errorCount[$objName] += 1 }
                                 
                    } else {if($objName -notin $skip){
                            # last good backup
                            $skip += $objName
                            
                        }
                    }
                }
            }
            $runNum += $thisSlurp
            $runCount -= $thisSlurp
        }
    }
}

$percentFailed = (($totalObjects-$totalFailedObjects)/$totalObjects).ToString("P")
 $HTML += "               <tr><td>{0}</td>
                              <td>{1}</td>
                              <td>{2}</td>
                              <td>{3}</td>
                              <td>{4}</td>
                              <td>{5}</td>
                              <td>{6}</td>
                              <td>{7}</td></tr>" -f $clustername, $totalObjects, $totalFailedObjects, $Successnum , $Warningnum, $Runningnum ,$Cancelednum,
$percentFailed
           
           }                   

$html += '</table>

</div>
</body>
</html>
'

$fileName = "./clients_summary_report.html"
$html | out-file $fileName

### send email report
foreach($toaddr in $sendTo){
    Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Cohesity Clients Summary Report" -BodyAsHtml $html -Attachments $fileName -WarningAction SilentlyContinue
}
#copy report to NAS share
$today = get-date
$targetPath = '\\hcohesity05.corpads.local\cohesity_reports'
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
$filename | Copy-Item -Destination $Directory
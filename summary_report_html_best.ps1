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
    [Parameter()][int]$slurp = 500,
    [Parameter()][int]$ibmcos1 = 346,
    [Parameter()][int]$ibmcos3 = 158
)
$today = Get-Date
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

################# HTML code ############################

$html = '<html>                                                       
<head>
<style type="text/css">
caption {  font-size: 1.5em;  font-weight: 400;  margin: 0;  padding: 6px 0 8px;  text-align: left;}
.table1 {border: 4px ;background:#cff;align:"center";cellpadding="0"; cellspacing="0";}
.table2 {border: 3px ; background:#E0F8AE;align:"left" ;cellpadding="20";cellspacing="0";}
.table3 {border: 4px ; background:#FFCAB1 ;align:"right";cellpadding="20" ;cellspacing="0";}

tr, td { font-size:16px; }
.content {width: 640px !important;}
td.fw {padding:25px 25px 25px 25px}
.th1 { border: solid 2px #ffffff; padding: 5px; background:#A6cb5b}
.th4 { border: solid 2px #ffffff; padding: 5px; background:#6DC7C7}
.th2 { border: solid 2px #ffffff; padding: 5px; background:#c7896b}
.th3 { border: solid 2px #ffffff; padding: 5px; background:#ECA583}
.td1 { border: solid 2px #ffffff; padding: 5px; }
.td2 { text-align: center; font-size: 1.5em; face:Tahoma; color:#D35400 ;}
.td3 { text-align: center; font-size: .5em; padding: 5px;color:#0000FF }
.td4 { text-align: center; font-size: .5em; padding: 5px;color:#D35400 }

</style>
<meta charset="utf-8">
<title> NestedTables </title>
</head>
<body >                                                       
<table width="100%" style="font-size: 15px;border-collapse: collapse;">
    <tr>
    <td class="td2">Daily Backup Summary Reports From ALL cluster</td>
    </tr>
	<tr>
    <td class="td3" >Below report also available on NAS share : \\hcohesity05\cohesity_reports </td></tr>
    <tr>
    <td class="td4" >Contact Anil Maurya for any question/comments on this report. </td></tr>
    
</table>'

#############################################

$clusters = ('Hcohesity01','Hcohesity03','Hcohesity04','Hcohesity05')
#$clusters = ('Hcohesity05')
$domain = 'corpads.local'
$allclusters = @{}

foreach ( $vip in $clusters) {
apiauth -vip $vip -username $username -domain corpads.local

if ($vip -notin $allclusters.keys){
                             $allclusters[$vip]= @{}
                             $allclusters[$vip]['changerate']= @{}
                                     }

$cluster = api get cluster
$clusterInfo = api get cluster?fetchStats=true
$clusterId = $clusterInfo.id


$jobs = api get "protectionJobs?isDeleted=false&isActive=true"


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
    ####from here #####
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
                    
                }else{
                    if($objName -notin $skip){
                        # last good backup
                        $skip += $objName
                        
                    }
                }
            }
        }
        $runNum += $thisSlurp
        $runCount -= $thisSlurp
    }
    }   ##### till here 
}


############jobs#############

$percentFailed = (($totalObjects-$totalFailedObjects)/$totalObjects).ToString("P")
$percentfailedr = (($totalObjects-$totalFailedObjects)/$totalObjects)

$allclusters[$vip]['percentFailed']= $percentFailed               ### take this for HTML
$allclusters[$vip]['percentfailedr'] = $percentfailedr           ### take this for HTML
$allclusters[$vip]['totalFailedObjects'] = $totalFailedObjects   ### take this for HTML
$allclusters[$vip]['totalObjects'] = $totalObjects                ### take this for HTML


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
        
        ####
        if($cluster.clusterSoftwareVersion -gt '6.5.1b' -and $job.environment -eq 'kView'){
            $stats = api get "stats/consumers?consumerType=kViewProtectionRuns&consumerIdList=$($job.id)"
        }else{
            $stats = api get "stats/consumers?consumerType=kProtectionRuns&consumerIdList=$($job.id)"
        }

        ####
        #$stats = api get "stats/consumers?consumerType=kProtectionRuns&consumerIdList=$($job.id)"
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
    ####
    if($cluster.clusterSoftwareVersion -gt '6.5.1b' -and $job.environment -eq 'kView'){
            $stats = api get "stats/consumers?consumerType=kViewProtectionRuns&consumerIdList=$($job.id)"
        }else{
            $stats = api get "stats/consumers?consumerType=kReplicationRuns&consumerIdList=$($job.id)"
        }
    ####
         #$stats = api get "stats/consumers?consumerType=kReplicationRuns&consumerIdList=$($job.id)"
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
             Write-Host "  Getting change Rate..."
            
             $jobSummary = api get '/backupjobssummary?_includeTenantInfo=true&allUnderHierarchy=true&includeJobsWithoutRun=false&isActive=true&isDeleted=false&numRuns=1000&onlyReturnBasicSummary=true&onlyReturnJobDescription=false'
             $found = $false
            foreach($job in $jobSummary | Sort-Object -Property { $_.backupJobSummary.jobDescription.name }){

	                    $startTimeUsecs = $job.backupJobSummary.lastProtectionRun.backupRun.base.startTimeUsecs
                        $endTimeUsecs = $job.backupJobSummary.lastProtectionRun.backupRun.base.endTimeUsecs
                        $jobId = $job.backupJobSummary.lastProtectionRun.backupRun.base.jobId

                        $lastrun = api get "/backupjobruns?allUnderHierarchy=true&exactMatchStartTimeUsecs=$startTimeUsecs&id=$jobId&onlyReturnDataMigrationJobs=false"
                             #####09/01
                                              
                             foreach($task in $lastrun.backupJobRuns.protectionRuns[0].backupRun.latestFinishedTasks){
                             $entity = $task.base.sources[0].source.displayName
                             $dataWritten = $task.base.totalPhysicalBackupSizeBytes
                            $logicalSize = $task.base.totalLogicalBackupSizeBytes
                            
                                 if ( $logicalSize -gt 0 ) {
                                 $changeRate = $dataWritten / $logicalSize
                                 $changeRatePct = [math]::Round(100 * $changeRate, 1)
                                   
                                        }
                                                            
                               
                                if ( $changeRatePct -gt 10 ) {
                                            write-host "...$changeRatePct"

                                          if ($entity -notin $allclusters[$vip]['changerate'].keys ) {
                                                               $allclusters[$vip]['changerate'][$entity] = $changeRatePct             ### take this for HTML
                                                               
                                                               $found = $True                                             ### take this for HTML
                                                                        }
                                                                       
                                             } 
                                             


        }
      
               ####09/01
}
                        
           Write-Host "  Getting cluster stats..."                                           
#################3change rate ##########
    ######################stats########################33
##########stats#######3
$clusteractualsize = [math]::Round($stat2Consumed  / (1024), 2)
$alltotal =  [math]::Round($totalsize / (1024), 2)
$alltotallogical = [math]::Round($totallogical / (1024), 2)
$percentused = ($alltotal/$clusteractualsize).ToString("P")
$allclusters[$vip]['clusterPhysicalsize'] = $clusteractualsize      ### take this for HTML
$allclusters[$vip]['alltotallogicalBackupsize'] = $alltotallogical  ### take this for HTML
$allclusters[$vip]['alltotalphysicalconsumed'] = $alltotal          ### take this for HTML
$allclusters[$vip]['OverallclusterUsageinPer'] = $percentused       ### take this for HTML

################stats#########
################change rate ##########3
### add IBM COS usage here ###########
Write-Host "  Getting IBMCOS numbers..."

if ( $VIP -in ('Hcohesity01','Hcohesity03')) {
                                                $TB = (1024*1024*1024*1024)
                                              if ($VIP -eq 'Hcohesity01'){
                                                        $vault = api get vaults | Where-Object name -eq 'HC1Archive1_ICOS'
                                                        $stats = api get "statistics/timeSeriesStats?entityId=$($vault.id)&metricName=kMorphedUsageBytes&metricUnitType=0&range=day&schemaName=kIceboxVaultStats&startTimeMsecs=1630468800000”
                                                        $consumed = $stats.dataPointVec.data[-1].int64Value/$TB
                                                        $statConsumed =  [math]::Round($consumed)
                                                        $percentused = ($statConsumed/$ibmcos1).ToString("P")
                                                        $allclusters[$vip]['ibmCosConsumed'] = $statConsumed    ### take this for HTML
                                                        $allclusters[$vip]['ibmCospercentused'] = $percentused  ### take this for HTML
                                                        }else {

                                                        $vault = api get vaults | Where-Object name -eq 'HC3Archive1_ICOS'
                                                        $stats = api get "statistics/timeSeriesStats?entityId=$($vault.id)&metricName=kMorphedUsageBytes&metricUnitType=0&range=day&schemaName=kIceboxVaultStats&startTimeMsecs=1630468800000”
                                                        $consumed = $stats.dataPointVec.data[-1].int64Value/$TB
                                                        $statConsumed =  [math]::Round($consumed)
                                                        $percentused = ($statConsumed/$ibmcos3).ToString("P")
                                                        $allclusters[$vip]['ibmCosConsumed'] = $statConsumed    ### take this for HTML
                                                        $allclusters[$vip]['ibmCospercentused'] = $percentused  ### take this for HTML
                                                        }

                                             }


#####################################
}

########################## write tables ##########################3
Write-Host "  Creating HTML Code..."
$allclusters.GetEnumerator()| Sort-Object { $_.name}| ForEach-Object  {
$html +='
<table class="table1" style="margin-left:auto; margin-right:auto;width:"100%"; border:"4px solid green"; border-collapse: collapse;" >                     
<tr> <th  colspan="2" class="th4"> ' + $_.name + ' Cluster Daily stats </th> </tr>
<tr>                                                          <! start of first row in main table  >
<td >                                                         <! start of first cell in first row in main table  >
<table class="table2">                                                       <! start of top left table  >
<tr> <th class="th1"> Cluster Parameter</th> <th class="th1"> Value </th> </tr>

<tr> <td class="td1"> Number of Backup Failure </td>
<td class="td1"> ' + $_.value.totalFailedObjects + ' </td> </tr>

<tr> <td class="td1"> Total backup Jobs </td>
<td class="td1"> ' + $_.value.totalObjects + ' </td> </tr>

<tr> <td class="td1"> Total Front End backup size in TB </td>
<td class="td1"> ' + $_.value.alltotallogicalBackupsize + ' </td> </tr>

<tr> <td class="td1"> Over All backup success </td>
'

if ($_.value.percentFailedr -lt 1 ){
$html +='
<td class="td1"><span style="color: #FF0000">' + $_.value.percentFailed + ' </td> </tr>
'
                                  } else { 
                                  $html +='
                                  <td class="td1"><span style="color: #0000FF"> ' + $_.value.percentFailed + ' </td> </tr>
                                  '
                                  }
        

$html +='
<tr> <td class="td1"> Cluster actual physical Size in TB</td>
<td class="td1"> ' + $_.value.clusterPhysicalsize + ' </td> </tr>

<tr> <td class="td1"> Physical space consumed in TB </td>
<td class="td1"> ' + $_.value.alltotalphysicalconsumed + ' </td> </tr>

<tr> <td class="td1"> Over All cluster Usage % </td>
<td class="td1"> ' + $_.value.OverallclusterUsageinPer + '</td> </tr>
'

                   if ( $_.name -in ('Hcohesity01','Hcohesity03')){
                        $html +='
                        <tr> <td class="td1"> IBMCOS Usage in TB </td>
                        <td class="td1"> ' + $_.value.ibmCosConsumed + ' </td> </tr>
                        <tr> <td class="td1"> IBMCOS Usage % </td>
                        <td class="td1"> ' + $_.value.ibmCospercentused + ' </td> </tr>
                        </table>                                                      
                        </td>                                                         
                        <td>'
                          } else {
                                 $html +='
                                </table>                                                      
                                </td>                                                         
                                <td>'
                                 }

                                                           

"###Cluster_name #### percentFailed ##### percentFailed ##### totalFailedObjects ##### totalObjects ##### clusterPhysicalsize ###### alltotallogicalBackupsize ###### alltotalphysicalconsumed ########OverallculsterUsageinPer #######ibmCosConsumed ######ibmCospercentused"
"##############################################################################################################################################################"
"{0,10}  {1,10}  {2,10} {3,10} {4,10}  {5,10}  {6,10} {7,10}  {8,10}  {9,10}" -f $_.name,$_.value.percentFailed,$_.value.totalFailedObjects,$_.value.totalObjects,$_.value.clusterPhysicalsize, $_.value.alltotallogicalBackupsize,$_.value.alltotalphysicalconsumed,$_.value.OverallclusterUsageinPer,$_.value.ibmCosConsumed,$_.value.ibmCospercentused

"########################## change Rate ########################################"
           $html +='
           <table class="table3">
                                <tr> <th class="th2" colspan="2"> Servers with Change Rate more than 10% </th> </tr>                                                       <! start of right top table >
                                <tr> <th class="th3"> Servers Name </th>
                                <th class="th3"> change Rate</th></tr>

           '
           
           if ($_.value.changerate.count -gt 0 ){
           $_.value.changerate.GetEnumerator()| Sort-Object { $_.name}| ForEach-Object  {
                                                                        
                             #"{0,-20}  {1,10}" -f $_.name,$_.value
                                $html +='
                                <tr> <td class="td1"> ' + $_.name +' </td>
                                <td class="td1"> '+ $_.value +' </td> </tr>
                                                                         
                                '
                                                                        }
                                                                        } else {
                                                                        
                                                                        $html +='
                                                                        <tr> <td class="td1" colspan="2"> No Server found. </td> </tr>
                                                                          
                                                                        '

                                                                         }
                                $html +='
                                </table> </td> </tr> 
                                </table>
                                '
}
##################################################################

#write-host ".......now3"
#$allclusters.hcohesity04.changerate

$HTML += '
                                                              
</body>                                                                
</html>  
'                                                               
$fileName = "./Cohesity_daily_summary_report.html"

$html | out-file $fileName
      Write-Host "  Sending email..."
foreach($toaddr in $sendTo){
    Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Cohesity enviornment Daily Summary Report" -BodyasHTML $html -Attachments $fileName -WarningAction SilentlyContinue
    }
#copy report to NAS share
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
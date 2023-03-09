### process commandline arguments
[CmdletBinding()]
param (
    [Parameter()][string]$vip='helios.cohesity.com',
    [Parameter()][string]$username = 'helios',
    [Parameter()][string]$domain = 'local',
    [Parameter()][int]$olderthan = 100,
    [Parameter()][array]$jobName, #jobs for which user wants to list/cancel replications
    [Parameter()][string]$joblist = '',
    [Parameter()][switch]$alljobs,
    [Parameter()][string]$remotecluster, # target cluster 
    [Parameter()][switch]$totalsize,
    [Parameter()][int]$numRuns = 999    
)

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

# authenticate
apiauth -vip $vip -username $username -domain $domain 

$outfile = $(Join-Path -Path $PSScriptRoot -ChildPath "out_$((get-date).ToString('yyyy-MM-dd')).txt")

### create excel spreadsheet
$xlsx = Join-Path -Path (Get-Location).Path -ChildPath "Replication_list-$(get-date -UFormat '%Y-%m-%d-%H-%M-%S').xlsx"
write-host "Saving Report to $xlsx..."
$excel = New-Object -ComObject excel.application
$workbook = $excel.Workbooks.Add()
$worksheets=$workbook.worksheets
$sheet=$worksheets.item(1)
$sheet.activate | Out-Null

### Column Headings
$sheet.Cells.Item(1,1) = 'Source Cluster'
$sheet.Cells.Item(1,2) = 'Start Date'
$sheet.Cells.Item(1,3) = 'Job Name'
$sheet.Cells.Item(1,4) = 'Group ID'
$sheet.Cells.Item(1,5) = 'Snapshot Sise in GB'
$sheet.Cells.Item(1,6) = 'Target Cluster'
$sheet.Cells.Item(1,7) = 'Expiry Date'
$sheet.usedRange.rows(1).font.colorIndex = 10
$sheet.usedRange.rows(1).font.bold = $True
$rownum = 2

# gather list from command line params and file
function gatherList($Param=$null, $FilePath=$null, $Required=$True, $Name='items'){
    $items = @()
    if($Param){
        $Param | ForEach-Object {$items += $_}
    }
    if($FilePath){
        if(Test-Path -Path $FilePath -PathType Leaf){
            Get-Content $FilePath | ForEach-Object {$items += [string]$_}
        }else{
            Write-Host "Text file $FilePath not found!" -ForegroundColor Yellow
            exit
        }
    }
    if($Required -eq $True -and $items.Count -eq 0){
        Write-Host "No $Name specified" -ForegroundColor Yellow
        exit
    }
    return ($items | Sort-Object -Unique)
}

if ($alljobs){

             $jobs = api get protectionJobs | Where-Object {$_.isDeleted -ne $True}
             $jobnames = $jobs.name
             }elseif ($jobName -or $joblist)  {
             $jobNames = @(gatherList -Param $jobName -FilePath $jobList -Name 'jobs' -Required $false)
             }




$runningTasks = @{}
foreach ($job in $jobNames){


    $jobId = (api get protectionJobs | Where-Object {$_.name -eq $job}).id
    
    $thisJobName = $jOb
    $runningTasks[$thisJobName] = @{}
        "Getting tasks for $JOB"
        $myruns = api get "protectionRuns?jobId=$jobId&numRuns=$numRuns&excludeTasks=true" 
        
        foreach($run in $myruns){
        
            $runStartTimeUsecs = $run.backupRun.stats.startTimeUsecs
            #$Run |ConvertTo-Json -Depth 25 |Out-File -FilePath $outfile|
            #$run.copyRun | ConvertTo-Json -Depth 10 |Out-File -filepath $outfile
            
            $run.copySnapshotTasks.stats.logicalBytesTransferred
            foreach($copyRun in $($run.copyRun | Where-Object {$_.status -eq "KSuccess" -and $_.target.replicationTarget.clusterName -eq $remotecluster})){
                #$copyRun |ConvertTo-Json -Depth 50 |Out-File -FilePath $outfile
                $startTimeUsecs = $runStartTimeUsecs
                $copyType = $copyRun.target.type
                $repsize = [math]::Round($copyrun.stats.logicalBytesTransferred/ (1024 * 1024 * 1024), 2)
                $status = $copyRun.status
                $expiry = $copyRun.expiryTimeUsecs
                $target = $copyRun.target.replicationTarget.clusterName                
                $clusterid =   $copyRun.taskUid.clusterId
                $clusterincar =   $copyRun.taskUid.clusterIncarnationId      
                
                                 #############populating hash table ##########
                if($copyType -eq 'kRemote'){
                         $runningTask = @{
                        
                        "jobId" = $jobId;
                        "startTimeUsecs" = $runStartTimeUsecs;
                        "copyType" = $copyType;
                        "status" = $status
                        "repsize" = $repsize
                        "expiry"  = $expiry             
                        "target"  = $target
                        "clusterid" = $clusterid
                        "clusterincar" = $clusterincar 
                    }
                    $runningTasks[$thisJobName][$startTimeUsecs] = $runningTask
                }
                #############populating hash table end ##########

                                 
            }
        }
       

     
    
                     }

                 if ($totalsize){
                 
                                          "`n`nStart Time                  Job Name                                                   Group ID                 Group Siz in GB     Expiry date"
    "----------                  --------                                                   ===============         ===============     ========="
                 $olderusecs = dateToUsecs ((Get-Date).AddDays(-$olderthan))

                 $runningTasks.GetEnumerator()|%{

                 $repoldsize = 0
                 
                 foreach ($job in $_.value.GetEnumerator()){
                          if ($job.key -lt $olderusecs){

        if ($job.value.repsize -gt $repoldsize){

                                   $repoldsize =   $job.value.repsize 
                                   $oldstart = $job.value.startTimeUsecs
                                   $jd= $job.value.jobId
                                   $expiry = $job.value.expiry
                                   }



                                                     }
         

                }
                if ($repoldsize -gt 0){

            $grandtotal += $repoldsize
        "{0,-25}   {1,-50}          {2,-15}          {3,-15}    {4,-15}" -f (usecsToDate $oldstart),$($_.name), $jd , $repoldsize,$expiry 
        }

                 }
                 
                 
                 }else{
                               
                                          "`n`nStart Time                  Job Name                                                   Group ID                 Group Siz in GB     Expiry date"
    "----------                  --------                                                   ===============         ===============      ========="
                                      $runningTasks.GetEnumerator()|%{
                      
                 foreach ($job in $_.value.GetEnumerator()){
                          if ($job.value.repsize -gt 0){
                                     
      #  "{0,-25}   {1,-50}          {2,-15}          {3,-15}     {4,-15}     {5,-15}" -f (usecsToDate $job.name).tostring('MM-dd-yyyy'),$($_.name), $($job.value.jobId) , $($job.value.repsize),$((usecsToDate $job.value.expiry).tostring('MM-dd-yyyy')),$($job.value.target)
        
        ####### populate Excel sheet
if($job.isActive -ne $false ){  #3
        $sheet.Cells.Item($rownum,1) = $vip
        $sheet.Cells.Item($rownum,2) = (usecsToDate $job.name).tostring('MM-dd-yyyy')
        $sheet.Cells.Item($rownum,3) = $_.name
        $sheet.Cells.Item($rownum,4) = $job.value.jobId
        $sheet.Cells.Item($rownum,5) = $job.value.repsize
        $sheet.Cells.Item($rownum,6) = $job.value.target
        $sheet.Cells.Item($rownum,7) = (usecsToDate $job.value.expiry).tostring('MM-dd-yyyy')
        $jobUrl = "https://$vip/protection/group/run/replication/$($job.value.clusterid):$($job.value.clusterincar):$($job.value.jobid)/$($job.value.jobid):$($job.name)"
        $sheet.Hyperlinks.Add(
            $sheet.Cells.Item($rownum,3),
            $jobUrl
        ) | Out-Null

        $rownum += 1
    }   #3
    ################end of excel sheet population
        
        }

                 }
                     }
                     }
"=========================================================="
write-host "Grand Total replicated FET Data on Target cluster in TB : $([math]::Round($grandtotal/1024, 2))"

### final formatting and save
$sheet.columns.autofit() | Out-Null
$sheet.columns("Q").columnWidth = 100
$sheet.columns("Q").wraptext = $True
$sheet.usedRange.rows(1).Font.Bold = $True
$excel.Visible = $true
$workbook.SaveAs($xlsx,51) | Out-Null
$workbook.close($false)
$excel.Quit()
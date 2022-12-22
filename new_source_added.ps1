### process commandline arguments
[CmdletBinding()]
param (
[Parameter()][array]$allvip = '', # Cohesity cluster to connect to
[Parameter()][int]$days = 30, 
[Parameter(Mandatory = $True)][string]$username

)

Remove-Item lastrun.txt -ErrorAction SilentlyContinue
### source the cohesity-api helper code
. ./cohesity-api

$report = @{}
$sourcerep = @{}
$today = Get-Date
if($allvip){
$vips = @($allvip) }else {

#$vips = ('chyusnpccp01','chyusnpccp02','chyusnpccp03','chyusnpccp05','chyuswpccp01','chyuswpccp02','chyuswpccp03','chyuswpccp05','chyukpccp01','chyukrccp01','chysgpccp01','chysgrccp01','chymaidcp01','chyididcp01')
$vips = ('chyusnpccp01','chyuswpccp01','chyusnpccp02','chyuswpccp02','chyusnpccp05','chyuswpccp05','chyusnpccp03','chyuswpccp03')
#$vips = ('cohsdcu01')
                     }

### create excel spreadsheet
$xlsx = Join-Path -Path (Get-Location).Path -ChildPath "New_capacity_added_since_last_month-$(get-date -UFormat '%Y-%m-%d-%H-%M-%S').xlsx"
write-host "Saving Report to $xlsx..."
$excel = New-Object -ComObject excel.application
$workbook = $excel.Workbooks.Add()
$worksheets=$workbook.worksheets
$sheet=$worksheets.item(1)
$sheet.activate | Out-Null
### Column Headings
$sheet.Cells.Item(1,1) = 'Cohesity Cluster'
$sheet.Cells.Item(1,2) = 'Server Name'
$sheet.Cells.Item(1,3) = 'Job Name'
$sheet.Cells.Item(1,4) = 'Logical Size'
$rownum = 2


foreach ($vip in $vips){
### authenticate
apiauth -vip $vip -username $username -domain ent.ad.ntrs.com
$newsources = @()
$oldsources = @()




"Inspecting sources on $vip ......" 
foreach ($job in (api get protectionJobs?allUnderHierarchy=true|`
where-object {$_.isActive -ne $False -and $_.isDeleted -ne $True -and $_.jobname -notlike "*DELETED*"})){
        
        $oldruns = api get protectionRuns?jobId=$($job.id)`&numRuns=99999`&excludeNonRestoreableRuns=true`&runTypes=kFull`&runTypes=kRegular`&startTimeUsecs=$(timeAgo $days days)`&endTimeUsecs=$(timeAgo $($days-1) days)
        $newruns = api get protectionRuns?jobId=$($job.id)`&numRuns=99999`&excludeNonRestoreableRuns=true`&runTypes=kFull`&runTypes=kRegular`&startTimeUsecs=$(timeAgo 1 days)
       
        foreach ($run in $oldruns){
        
                   foreach($source in $run.backupRun.sourceBackupStatus){
                    $sourcename = $source.source.name
                    if($sourcename -notin $oldsources){
                        $oldsources += $sourcename
                        
                                                    }
                    
                                                                          }
           
                              } ##oldrun
       
        foreach ($run in $newruns){
        
                   foreach($source in $run.backupRun.sourceBackupStatus){
                    $sourcename = $source.source.name
                    if ($sourcename -notin $sourcerep.keys){
                             $sourcerep[$sourcename] = @{}
                             $sourcerep[$sourcename]['logicalsize']= [math]::Round((($source.stats.totalLogicalBackupSizeBytes)/1024/1024/1024),2)
                                                     }

                    if($sourcename -notin $newsources){
                        $newsources += $sourcename
                        
                                                    }
                    
                                                                          }
           
                              } ##newrun
                              
                              foreach ($source in $newsources){
                              
                                    if ($source -notin $report.keys){
                                               if ($oldsources -notcontains $source){
                                               $report[$source]=@{}
                                               $report[$source]['cluster']= $vip
                                               $report[$source]['job']= $job.name
                                               $report[$source]['jobid']= $job.id
                                               $sourcerep.Getenumerator()|ForEach-Object{
                                                            if ($source -match $_.key){
                                                                        $logicals = $_.value.logicalsize
                                                                                     }
                                                                                     }
                                               $report[$source]['logicalsize']= $logicals

                                                                                     }
                                                                 }
                                                                }
   
                                                                                                         }    
                       
                         }
    
    $report.GetEnumerator()|foreach-object {

    $sheet.Cells.Item($rownum,1) = $_.value.cluster
        $sheet.Cells.Item($rownum,2) = $_.name
        $sheet.Cells.Item($rownum,3) = $_.value.job
        $sheet.Cells.Item($rownum,4) = $_.value.logicalsize
      
    $jobUrl = "https://$($_.value.cluster)/protection/job/$($_.value.jobid)/details"
    $sheet.Hyperlinks.Add(
            $sheet.Cells.Item($rownum,3),
            $jobUrl
        ) | Out-Null
        $rownum += 1
    #>
        
    "{0,-45}  {1,-10} {2,-50}  {3,-10}" -f  $_.name , $_.value.cluster,$_.value.job ,$_.value.logicalsize
         
        
                                          }
    ### final formatting and save
$sheet.columns.autofit() | Out-Null
$sheet.columns("Q").columnWidth = 100
$sheet.columns("Q").wraptext = $True
$sheet.usedRange.rows(1).Font.Bold = $True
$excel.Visible = $true
$workbook.SaveAs($xlsx,51) | Out-Null
$workbook.close($false)
$excel.Quit()

#copy report to NAS share
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
$xlsx | Copy-Item -Destination $Directory
     
                                        
    #$report|ConvertTo-Json

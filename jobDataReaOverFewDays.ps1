[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][string]$domain = 'local',
    [Parameter(Mandatory = $True)][array]$jobNames, # job to run
    [Parameter()][int]$Days
)

### source the cohesity-api helper code
. ./cohesity-api

### authenticate
apiauth -vip $vip -username $username -domain $domain

$dayusec  = [int64](((Get-Date).ToUniversalTime())-([datetime]"1970-01-01 00:00:00")).TotalSeconds*1000000

$TB = 1024*1024*1024*1024

$dateString = (get-date).ToString().Replace(' ','_').Replace('/','-').Replace(':','-')
#$outfileName = "RunStats-$dateString.csv"
#"JobName,Job start Time,Status,RunType,Duration in Min, ReadGBytes, writeGBytes" | Out-File -FilePath $outfileName

$endtime = $dayusec
$data = @{}
$jobs = api get protectionJobs?isDeleted=false
$dates =@()
            for ($day=1;$day -lt $days -or $day  -eq $days;$day ++){
                $dates += ((get-date).AddDays(-$day)).ToString('yyyy-MM-dd')
                                                                  }
                $dates = ,"Job_Name" + $dates
                
foreach ($jobname in $jobNames){   ###1
       $endtime = $dayusec
       
        for ($day=1;$day -lt $days -or $day  -eq $days;$day ++){   ###2
               
               $starttime = [int64](((Get-Date).ToUniversalTime())-([datetime]"1970-01-01 00:00:00")).TotalSeconds*1000000 - ($day * 86400000000)
                    if ($jobname -notin $data.keys){
                             $data[$jobname]=@{}
                                                }


                        foreach ($job in $jobs){     #  starts jobs loop
    
                                         if ( $jobname -eq $job.name){
                                           $jobId = $job.id
                                           #$starttime = $usec
                                           $runs = api get "protectionRuns?jobId=$($job.id)&startTimeUsecs=$starttime&endTimeUsecs=$endtime&runTypes=kRegular"
                                                                     }
                                               }

                            foreach ($run in $runs){
                                $nowTime = dateToUsecs (get-date)
                                $7thday = (dateToUsecs ((Get-Date).AddDays(-7)))
                                $startTime = $run.copyRun[0].runStartTimeUsecs
                                $date =  (usecsToDate $starttime).ToString('yyyy-MM-dd’)
                                        
                                     if ($run.backupRun.runType.substring(1) -eq "Regular"){   #  starts last day
            
                                    $readMBytes = [math]::Round($run.backupRun.stats.totalBytesReadFromSource / $TB, 3)
                                    $data[$jobname][$date]=$readMBytes
                                    
                                    #"$($jobName)     $($readMBytes) $($date)"
                                                                                             }
                 
                            }
                                        $endtime = $starttime
                                        
                                } ###2
                } ###1

                
                #"{0,-25} {1,10} {2,10} {3,10} {4,10} {5,10} {6,10} {7,10} {8,10} {9,10} {10,10} {11,10} {12,10} {13,10} {14,10}" -f "Job Name","2022-07-28","2022-07-27","2022-07-26","2022-07-25","2022-07-24","2022-07-23","2022-07-22","2022-07-21","2022-07-20","2022-07-19","2022-07-18","2022-07-17","2022-07-16","2022-07-15"
                
                #"==============================================================================================================="
                
                         $data.Keys | ForEach-Object {
  $projectName = $_
  $sortedSubKeys = $data[$_].Keys | Sort-Object
  [pscustomobject] $data[$_] | 
    Select-Object (, @{ Name='Project'; Expression={ $projectName } } + $sortedSubKeys)
} | Format-Table * | Out-String -Width 9999
                   
                   $data.Keys | ForEach-Object {
  $projectName = $_
  $sortedSubKeys = $data[$_].Keys | Sort-Object
  [pscustomobject] $data[$_] | 
    Select-Object (, @{ Name='Project'; Expression={ $projectName } } + $sortedSubKeys)
} | Export-Csv     -Path .\dataread.csv                            
                                              
                                             #$data | ConvertTo-JSON
                                              #[pscustomobject] $data.Aix_10pm | Format-Table 
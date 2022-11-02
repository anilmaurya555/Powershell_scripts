. .\cohesity-api.ps1
apiauth -vip hcohesity0566 -username amaurya -domain corpads.local
$jobname = get-content c:\anil\scripts\jobs.txt 
$jobs = @() 
foreach ( $job in $jobname){
                          $newjobs = api get protectionJobs| Where-Object name -ieq $job
                          $jobs += $newjobs
                          }

foreach ( $job in $jobs ) {
                             $jobid= $job.id
                             $jobname = $job.name -replace "_\d{1,2}",""
                             $min = $job.starttime.minute
                             if ($min -eq 0 ) { $min = "00"}
                             if ($job.starttime.hour -lt 12) {
                                         $oldtime= $job.starttime.hour
                                         $time = "$oldtime" + ":" + "$min" + "AM"}
                                         else {
                                              $newtime = $job.starttime.hour - 12
                                              $time = "$newtime" + ":" + "$min" + "PM"
                                              }
                             $job.name = $jobname +"_"+$time                           
                             $null = api put protectionJobs/$jobid $job
                             $job.name
                             } 

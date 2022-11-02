. .\cohesity-api.ps1
apiauth -vip hcohesity05 -username amaurya -domain corpads.local
$jobname = get-content c:\anil\scripts\jobs.txt 
$jobs = @() 
foreach ( $job in $jobname){
                          $newjobs = api get protectionJobs| Where-Object name -ieq $job
                          $jobs += $newjobs
                          }

foreach ( $job in $jobs ) {
                             $jobid= $job.id                             
                             $job.incrementalProtectionSlaTimeMins = 240
                             $job.fullProtectionSlaTimeMins = 1200
                             $null = api put protectionJobs/$jobid $job
                             $job.name
                             }

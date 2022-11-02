. .\cohesity-api.ps1
apiauth -vip hcohesity01 -username amaurya -domain corpads.local
$jobs = api get protectionJobs

$alljobs = @{}
foreach ( $job in $jobs ) {
                             $jobname = $job.name
                             $alljobs[$jobname] = @{}
                             $alljobs[$jobname]['hour'] = $job.starttime.hour

                             }
                             $alljobs.GetEnumerator()|ForEach-Object {
                             "{0,25} {1}" -f ($_.name,$_.value.hour)}

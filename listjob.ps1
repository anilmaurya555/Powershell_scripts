[cmdletbinding()]
param (
      [parameter ( mandatory = $True)][string]$vip,
      [parameter ()][array]$prefix= 'ALL',
      [parameter ()] [switch] $count
      )
. .\cohesity-api.ps1
apiauth -vip $vip -username amaurya -domain corpads.local
$jobs = (api get protectionJobs | Where-Object {$_.isdeleted -ne $True -and $_.isactive -ne $false})
forEach ($job in $jobs ){
                    $jobname= $job.name
                    if ($jobname.tolower() -like "*$prefix*" -or $prefix -eq 'ALL') {
                         $clients = @()
                         $sources = @{}
                         $report = api get reports/protectionSourcesJobsSummary?jobIds=$($job.id)
                         $newcount = 0
                         foreach($summary in $report.protectionSourcesJobsSummary){
                         if($summary.protectionSource.id -in $sources.Keys){ $sources[$summary.protectionSource.id] += $job.name }
                         else{ $sources[$summary.protectionSource.id] = @($job.name) } } 
                         ### gather source names and types
                         foreach ($source in $sources.Keys){                    
                                           $sourceObject = api get "protectionSources/objects/$source"
                                           $clients += $sourceObject.name                                            
                                           $newcount += 1       
                                                             }
                                                             if ($count) {
                                                             #"Total CLIENT ($newcount) in Job ($jobname)"
                                                            $jobname 
                                                             } else {
                                                             "`nJob name"
                                                             $jobname
                                                             "`nClinets list"
                                                             $clients}                                   
                         }
                         }
                         
                         
connect-CohesityCluster -Server sbch-dp01br.selective.com

$jobs = Get-CohesityProtectionJob
Get-CohesityProtectionSourceObject |set-content "C:\anil\powershell\input555.txt"
$sources = Get-CohesityProtectionSourceObject
#$sources = get-content "c:\anil\powershell\servers.txt"

foreach ($source in @($sources| where-object {$_.Environment -eq 'kVMware'})) { 
              $job = $jobs | Where-Object { $_.sourceIds -eq $source.id }

             if ($job.name -eq 'VM_Prod_7PM'){
                               $source.name

                             }
                             } 
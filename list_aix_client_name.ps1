connect-CohesityCluster -Server hcohesity03

$outfile = "aix_clients.txt"
$jobs = Get-CohesityProtectionJob
#Get-CohesityProtectionSourceObject |set-content "C:\anil\powershell\input555.txt"
$sources = Get-CohesityProtectionSourceObject
#$sources = get-content "c:\anil\powershell\servers.txt"
##### use KVMware for VM and KPhysical for physical #####
foreach ($source in @($sources| where-object {$_.Environment -eq 'KPhysical'})) { 
              $job = $jobs | Where-Object { $_.sourceIds -eq $source.id }

             if ($job.name -like "*AIX*"){
                               $source.name | out-file -FilePath $outfile -Append
                               #$source.name
                             }
                             } 
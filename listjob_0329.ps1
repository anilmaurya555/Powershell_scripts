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
                    $job.name
                    
                    }
                         
                         
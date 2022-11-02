# process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,  # the cluster to connect to (DNS name or IP)
    #[Parameter()][array]$jobName = '',  # optional name of one server protect
     [Parameter()][switch]$overwrite
    )

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

$jobnames= @()
foreach($j in $jobName){
    $jobnames += $j
}


# authenticate
apiauth -vip $vip -username amaurya -domain corpads.local


#$jobs = (api get "data-protect/protection-groups?isDeleted=false&isActive=true&environments=kPhysical&includeTenants=true" -v2).protectionGroups|Where-Object {$_.name -in $jobnames}
$jobs = (api get "data-protect/protection-groups?isDeleted=false&isActive=true&environments=kPhysical&includeTenants=true" -v2).protectionGroups

foreach($job in $jobs){
                      
                      
                      
                           if ($job.physicalParams.fileProtectionTypeParams.indexingPolicy.excludePaths -ne $null ){
                                
                                if($overwrite){
                                                            $job.physicalParams.fileProtectionTypeParams.indexingPolicy.excludePaths= $null
                                                            
                                                            write-host "$($job.name) has splunk exclusion, All exclusion removed."
                                                            $null = api put "data-protect/protection-groups/$($job.id)" $job -v2
                                                            }
                                                    }

                      
                      }

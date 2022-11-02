# process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,  # the cluster to connect to (DNS name or IP)
    #[Parameter()][array]$jobName = '',  # optional name of one server protect
    [Parameter()][string]$exclusionList = '',  # required list of exclusions
    [Parameter()][switch]$overwrite
    )

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

$jobnames= @()
foreach($j in $jobName){
    $jobnames += $j
}
# gather exclusion list
$excludePaths = @()

if('' -ne $exclusionList){
    if(Test-Path -Path $exclusionList -PathType Leaf){
        $exclusions = Get-Content $exclusionList
        foreach($exclusion in $exclusions){
            $excludePaths += [string]$exclusion
        }
    }else{
        Write-Warning "Exclusions file $exclusionList not found!"
        exit
    }
}

# authenticate
apiauth -vip $vip -username amaurya -domain corpads.local

#$jobs = (api get "data-protect/protection-groups?isDeleted=false&isActive=true&environments=kVMware&includeTenants=true" -v2).protectionGroups|Where-Object {$_.name -in $jobnames}
$jobs = (api get "data-protect/protection-groups?isDeleted=false&isActive=true&environments=kVMware&includeTenants=true" -v2).protectionGroups


foreach($job in $jobs){
                      
                      
                      
                           if ($job.vmwareParams.indexingPolicy.excludePaths.contains("/splunk") -or $job.vmwareParams.indexingPolicy.excludePaths.contains("/opt/splunk")){
                                
                                if($null -eq $globalExcludePaths -or $overwrite){
                                                          $job.vmwareParams.indexingPolicy.excludePaths=@($excludePaths )
                                
                                                            write-host "$($job.name) has splunk exclusion, now removed"
                                                            #$null = api put "data-protect/protection-groups/$($job.id)" $job -v2
                                                            }
                                                    }

                      
                      }

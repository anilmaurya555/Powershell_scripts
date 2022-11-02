### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][string]$domain = 'local',
    [Parameter(Mandatory = $True)][string]$sourceName
)

### source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

### authenticate
apiauth -vip $vip -username $username -domain $domain
            
             if($obj.protectionSource.name -eq $sourceName){
            $obj.physicalProtectionSource.agents[0].name
             $obj.protectionSource.physicalProtectionSource.agents[0].version 
           "$version`t$name"
                }
                
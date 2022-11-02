### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][string]$domain = 'local'
    
)
$serversToAdd = @()
$serversToAdd = Get-Content "c:\anil\servers.txt"
# source the cohesity-api helper code
. ./cohesity-api

# authenticate
apiauth -vip $vip -username $username -domain $domain

# get physical protection sources
$sources = api get protectionSources?environment=kPhysical

foreach($server in $serversToAdd){
    $node = $sources.nodes | Where-Object { $_.protectionSource.name -eq $server }
    
        $name=$node.protectionSource.physicalProtectionSource.agents[0].name
        $version= $node.protectionSource.physicalProtectionSource.agents[0].version 
       
       #"$name`t`t`t`t`t$version"
       "{0,-40}{1,-30}" -f $name, $version
        }
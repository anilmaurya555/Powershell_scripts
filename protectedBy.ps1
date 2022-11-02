### usage: ./protectedBy.ps1 -vip 192.168.1.198 -username admin -domain local -object myvm

### process commandline arguments
[CmdletBinding()]
param (
    #[Parameter(Mandatory = $True)][string]$vip,
    #[Parameter(Mandatory = $True)][string]$username,
   [Parameter()][array]$servers = '', # optional names of servers to protect (comma separated)
   [Parameter()][string]$serverList = '' # optional textfile of servers to protect
   
)

### source the cohesity-api helper code
. ./cohesity-api

#$clusters = ('hcohesity01.corpads.local','hcohesity03.corpads.local','hcohesity04.corpads.local','hcohesity05.corpads.local')
$clusters = ('hcohesity01','hcohesity03','hcohesity04','hcohesity05')
$domain = 'corpads.local'

# gather list of servers to check
if($serverList){
    $allservers = get-content $serverList
    }elseif($servers) {
        $allservers = @($servers)
    }else{
        Write-Warning "No Servers Specified"
        exit
    }

foreach ( $vip in $clusters) {

### authenticate
apiauth -vip $vip -username amaurya -domain $domain
$vip
# get protection jobs
$jobs = api get protectionJobs

# get root protection sources
$sources = api get protectionSources
$global:nodes = @()

# get flat list of protection source nodes
function get_nodes($obj){
    if($obj.PSObject.Properties['nodes']){
        foreach($node in $obj.nodes){
            get_nodes($node)
        }
    }else{
        $global:nodes += $obj
    }
}

foreach($source in $sources){
    get_nodes($source)
}

$foundNode = $false
$foundIds = @()
foreach ( $object in $allservers ){
foreach($node in $global:nodes){
    $name = $node.protectionSource.name
    $sourceId = $node.protectionSource.id

    # find matching node

    
    if($name -like "*$($object)*" -and $sourceId -notin $foundIds){
        $environment = $node.protectionSource.environment
        
        # find job that protects this node
        $job = $jobs | Where-Object {$_.sourceIds -eq $sourceId }
        if($job){
            $protectionStatus = "is protected by $($job.name)"
        }else{
            $protectionStatus = 'is unprotected'
        }
        
        # report result
        if($environment -ne 'kAgent'){
            "({0}) {1} ({2}) {3}" -f $environment, $name, $sourceId, $protectionStatus
            $foundNode = $True
            $foundIds += $sourceId
        }
    }
    ###
    } 
    ###
    # object not found
if(! $foundNode){
    "$object not found"
}
    #######
    }
}


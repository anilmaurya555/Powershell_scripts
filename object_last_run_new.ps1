 ### usage: ./objectRecoveryPoints.ps1 -vip mycluster -username myusername -domain mydomain.net -objectname *

### process commandline arguments
[CmdletBinding()]
param (
[Parameter(Mandatory = $True)][string]$vip,
[Parameter(Mandatory = $True)][string]$username,
[Parameter(Mandatory = $True)][string]$objectname,
[parameter ()] [switch] $lastrun
)

Remove-Item lastrun.txt -ErrorAction SilentlyContinue
### source the cohesity-api helper code
. ./cohesity-api

### authenticate
apiauth -vip $vip -username $username -domain corpads.local

$now = dateToUsecs (get-date)

########### get object full name ###########
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

foreach($node in $global:nodes){
    $name = $node.protectionSource.name
    $sourceId = $node.protectionSource.id

    # find matching node

    
    if($name -like "*$($objectname)*" -and $sourceId -notin $foundIds){
        
             
           $objectfullname = $name 
            $foundNode = $True
            $foundIds += $sourceId
        }
    }
    

################################################

### search for object
$realname = $objectfullname -split '\s+' -match '\S'
$realname2 = $realname[0]

$search = api get "/searchvms?vmName=$realname2"
$outfile = "lastrun.txt"

if(! $search.psobject.properties['vms']){

write-host "No objects found with name $objectname" -ForegroundColor Yellow
exit
}

$search.vms = $search.vms | Where-Object {$_.vmDocument.objectName -eq $realname2 }

"{0,-22}   {1,-45} {2,-22} {3,-18}   {4}" -f 'ObjectName', 'JobName', 'StartTime', 'ExpiryTime', 'DaysToExpiration'
"================================================================================================================================="

foreach($vm in $search.vms){
$jobName = $vm.vmDocument.jobName
$displayName = $vm.vmDocument.objectName
foreach($version in $vm.vmDocument.versions){
$startTime = usecsToDate $version.instanceId.jobStartTimeUsecs
$expiryTime = usecsToDate $version.replicaInfo.replicaVec[0].expiryTimeUsecs
$daysToExpire = [math]::Round(($version.replicaInfo.replicaVec[0].expiryTimeUsecs- $now)/(1000000*60*60*24))
      
                                "{0,-22} {1,-45} {2,-22} {3,-18}   {4}" -f $displayName, $jobName, $startTime, $expiryTime, $daysToExpire |out-file -FilePath $outfile -Append

                              
}
}
if ($lastrun) {
               $check = Test-Path -PathType leaf "C:\anil\scripts\lastrun.txt"
               
                  if ($check -eq $True) {get-content $outfile|Select-Object -First 1} else 
                         {
                         "====yes===here=="
                         write-host "No objects found with name $objectname" -ForegroundColor Yellow}
                } else { 
                
                $check = Test-Path -PathType leaf "C:\anil\scripts\lastrun.txt"
                
                     if ($check -eq $True) { get-content $outfile|ForEach-Object { write-host $_ }} else
                     {write-host "No objects found with name $objectname" -ForegroundColor Yellow}
            }
#get-content $outfile|Select-Object -last 1 
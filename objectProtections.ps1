### usage: ./objectProtectionDetails.ps1 -vip mycluster -username myusername -domain mydomain.net  
### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][string]$domain = 'local',
    [Parameter()][switch]$includeExpired
)

function getObjectId($objectName){
    $global:_object_id = $null

    function get_nodes($obj){

        if($obj.protectionSource.name -eq $objectName){
            $global:_object_id = $obj.protectionSource.id
            $global:object = $obj.protectionSource.name
            break
        }
        if($obj.name -eq $objectName){
            $global:_object_id = $obj.id
            $global:object = $obj.name
            break
        }        
        if($obj.PSObject.Properties['nodes']){
            foreach($node in $obj.nodes){
                if($null -eq $global:_object_id){
                    get_nodes $node
                }
            }
        }
        if($obj.PSObject.Properties['applicationNodes']){
            foreach($node in $obj.applicationNodes){
                if($null -eq $global:_object_id){
                    get_nodes $node
                }
            }
        }
    }
    
    foreach($source in $sources){
        if($null -eq $global:_object_id){
            get_nodes $source
        }
    }
    return $global:_object_id
}

### source the cohesity-api helper code
. ./cohesity-api

### authenticate
apiauth -vip $vip -username $username -domain $domain -quiet

# start logging
#$logfile = $(Join-Path -Path $PSScriptRoot -ChildPath log-archiveAndExtend.txt)
#"`nScript Run: $(Get-Date)" | Out-File -FilePath $logfile -Append

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

# get protection jobs
$jobs = api get protectionJobs
$foundids = @()

#$sources = api get protectionSources
 "Object Name                  Job Name            Start Time          End Time            Job Run  Type         Object   Read       Logical Size"
 "------------------           ------------------  -------  -----------  -------  ---------  ------------        -------------       ------------"
foreach($object in $global:nodes.protectionSource.name| Sort-Object | Get-Unique){
                            
                            # get object ID
                            $objectId = getObjectId $object
                                                       
                                # find protection job
                                $jobs = $jobs | Where-Object {
                                    $objectId -in $_.sourceIds -or
                                    $objectId -in $_.sourceSpecialParameters.oracleSpecialParameters.applicationEntityIds -or
                                    $objectId -in $_.sourceSpecialParameters.sqlSpecialParameters.applicationEntityIds
                                }
    
                                    foreach($job in $jobs){
                                                   
                                        # get protectionRuns
                                        $runs = api get "protectionRuns?jobId=$($job.id)&startTimeUsecs=$(dateToUsecs (get-date).AddHours(-24))&endTimeUsecs=$(dateToUsecs (get-date))&numRuns=999999"
                                        if($includeDeleted -eq $false){
                                            $runs = $runs | Where-Object { $_.backupRun.snapshotsDeleted -eq $false }
                                        }
                                        foreach($run in $runs){
                                            # runs stats
                                            $runStart = $run.backupRun.stats.startTimeUsecs
                                            $runEnd = $run.backupRun.stats.endTimeUsecs
                                            $runStatus = $run.backupRun.status.subString(1)
                                            $runType = $run.backupRun.runType.substring(1).replace('Regular','Incremental')
                                            $objLogical = ''
                                            $objLogicalUnits = ''
                                            $objRead = ''
                                            $objReadUnits = ''
                                            $objStatus = ''
                                            $objStart = (usecsToDate $runStart).ToString("MM/dd/yyyy hh:mmtt")
                                            $objEnd = (usecsToDate $runEnd).ToString("MM/dd/yyyy hh:mmtt")
                                            if($run.backupRun.PSObject.Properties['warnings']){
                                                $runStatus = 'Warning'
                                            }
                                            if($run.backupRun.PSObject.Properties['sourceBackupStatus']){
                                                # object stats
                                                foreach($source in $run.backupRun.sourceBackupStatus){
                                                    if($source.source.name -eq $object){
                                                        $objStatus = $source.status.subString(1)
                                                        if($source.PSObject.Properties['warnings']){
                                                            $objStatus = 'Warning'
                                                        }
                                                        $objLogical = $source.stats.totalLogicalBackupSizeBytes
                                                        $objLogicalUnits = 'B'
                                                        $objRead = $source.stats.totalBytesReadFromSource
                                                        $objReadUnits = 'B'
                                                        if($objLogical -ge 1073741824){
                                                            $objLogical = [math]::round(($objLogical/1073741824),1)
                                                            $objLogicalUnits = 'GiB'
                                                        }elseif ($objLogical -ge 1048576) {
                                                            $objLogical = [math]::round(($objLogical/1048576),1)
                                                            $objLogicalUnits = 'MiB'                                                              
                                                        }elseif ($objLogical -ge 1024) {
                                                            $objLogical = [math]::round(($objLogical/1024),1)
                                                            $objLogicalUnits = 'KiB'                                                              
                                                        }
                                                        if($objRead -ge 1073741824){
                                                            $objRead = [math]::round(($objRead/1073741824),1)
                                                            $objReadUnits = 'GiB'
                                                        }elseif ($objRead -ge 1048576) {
                                                            $objRead = [math]::round(($objRead/1048576),1)
                                                            $objReadUnits = 'MiB'                                                              
                                                        }elseif ($objRead -ge 1024) {
                                                            $objRead = [math]::round(($objRead/1024),1)
                                                            $objReadUnits = 'KiB'                                                              
                                                        }
                                                        $objStart = (usecsToDate $source.stats.startTimeUsecs).ToString("MM/dd/yyyy hh:mmtt")
                                                        $objEnd = (usecsToDate $source.stats.endTimeUsecs).ToString("MM/dd/yyyy hh:mmtt")
                                                    }
                                                }
                                            }
                
                                           "{0,-25}    {1,-15}    {2,-19} {3,-19} {4,-8} {5,-12} {6,-8} {7,5} {8,-4} {9} {10,2}" -f $global:object, $job.name, $objStart, $objEnd, $runStatus, $runType, $objStatus, $objRead, $objReadUnits, $objLogical, $objLogicalUnits
                                            
                                        }
                                    }
                                   
                                  
    }   
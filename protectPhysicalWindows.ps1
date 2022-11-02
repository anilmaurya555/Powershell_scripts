# usage: ./protectWindows.ps1 -vip mycluster `
#                             -username myusername `
#                             -domain mydomain.net `
#                             -servers server1.mydomain.net, server2.mydomain.net `
#                             -jobName 'File-based Windows Job' `
#                             -exclusions 'c:\windows', 'e:\excluded', 'c:\temp' `
#                             -serverList .\serverlist.txt `
#                             -exclusionList .\exclusions.txt `
#                             -allDrives `
#                             -skipNestedMountPoints

# process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,  # the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username,  # username (local or AD)
    [Parameter()][string]$domain = 'local',  # local or AD domain
    [Parameter()][array]$servers = '',  # optional names of servers to protect (comma separated)
    [Parameter()][string]$serverList = '',  # optional textfile of servers to protect
    [Parameter()][array]$inclusions = '', # optional paths to exclude (comma separated)
    [Parameter()][string]$inclusionList = '',  # optional list of exclusions in file
    [Parameter()][array]$exclusions = '', # optional paths to exclude (comma separated)
    [Parameter()][string]$exclusionList = '',  # optional list of exclusions in file
    [Parameter(Mandatory = $True)][string]$jobName,  # name of the job to add server to
    [Parameter()][switch]$skipNestedMountPoints,  # if omitted, nested mountpoints will not be skipped
    [Parameter()][switch]$overwriteAll,
    [Parameter()][switch]$allDrives
)

# gather list of servers to add to job
$serversToAdd = @()
foreach($server in $servers){
    $serversToAdd += $server
}
if ('' -ne $serverList){
    if(Test-Path -Path $serverList -PathType Leaf){
        $servers = Get-Content $serverList
        foreach($server in $servers){
            $serversToAdd += [string]$server
        }
    }else{
        Write-Warning "Server list $serverList not found!"
        exit
    }
}

# gather inclusion list
$includePaths = @()
foreach($inclusion in $inclusions){
    $includePaths += $inclusion
}
if('' -ne $inclusionList){
    if(Test-Path -Path $inclusionList -PathType Leaf){
        $inclusions = Get-Content $inclusionList
        foreach($inclusion in $inclusions){
            $includePaths += [string]$inclusion
        }
    }else{
        Write-Warning "Inclusions file $inclusionList not found!"
        exit
    }
}
if(! $includePaths){
    if(! $allDrives){
        Write-Host "No include paths specified" -ForegroundColor Yellow
        exit 1
    }
}

# gather exclusion list
$excludePaths = @()
foreach($exclusion in $exclusions){
    $excludePaths += $exclusion
}
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

if($skipNestedMountPoints){
    $skip = $True
}else{
    $skip = $false
}

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

# authenticate
apiauth -vip $vip -username $username -domain $domain -password $password

# get cluster info
$cluster = api get cluster

# get the protectionJob
$job = api get protectionJobs | Where-Object {$_.name -ieq $jobName}
if(!$job){
    Write-Warning "Job $jobName not found!"
    exit
}

# get physical protection sources
$sources = api get protectionSources?environment=kPhysical

# add sourceIds for new servers
$sourceIds = @($job.sourceIds)
$newSourceIds = @()

foreach($server in $serversToAdd | Where-Object {$_ -ne ''}){
    $server = $server.ToString()
    $node = $sources.nodes | Where-Object { $_.protectionSource.name -eq $server }
    if($node){
        if($node.protectionSource.physicalProtectionSource.hostType -eq 'kWindows'){
            $sourceId = $node.protectionSource.id
            $sourceIds += $sourceId
            $newSourceIds += $sourceId
        }else{
            Write-Warning "$server is not a Windows host"
        }
    }else{
        Write-Warning "$server is not a registered source"
    }
}

$sourceIds = @($sourceIds | Select-Object -Unique)

$existingParams = $job.sourceSpecialParameters
$newParams = @()
foreach($sourceId in $sourceIds){
    $newParam = @{
        "sourceId" = $sourceId;
        "physicalSpecialParameters" = @{
            "filePaths" = @()
        }
    }

    # get source mount points
    $source = $sources.nodes | Where-Object {$_.protectionSource.id -eq $sourceId}
    "  processing $($source.protectionSource.name)"
    $mountPoints = $source.protectionSource.physicalProtectionSource.volumes.mountPoints | Where-Object {$_ -ne $null -and $_ -ne ''}

    # get new include / exclude paths to process
    $includePathsToProcess = $includePaths | Where-Object {$_ -ne $null -and $_ -ne ''}
    $excludePathsToProcess = $excludePaths | Where-Object {$_ -ne $null -and $_ -ne ''}
    $excludePathsProcessed = @()

    # get existing include / exclude paths
    $theseParams = $existingParams | Where-Object {$_.sourceId -eq $sourceId}
    if($theseParams -and ! $overwriteAll){
        $excludePathsToProcess += $theseParams.physicalSpecialParameters.filePaths.excludedFilePaths
        $includePathsToProcess += $theseParams.physicalSpecialParameters.filePaths.backupFilePath
    }
    
    # process exclude paths
    $wildCardExcludePaths = $excludePathsToProcess | Where-Object {$_.subString(0,2) -eq '*:'}
    $excludePathsToProcess = $excludePathsToProcess | Where-Object {$_ -notin $wildCardExcludePaths}
    foreach($wildCardExcludePath in $wildCardExcludePaths){
        foreach($mountPoint in $mountPoints){
            $excludePathsToProcess += "$($mountPoint):" + $wildCardExcludePath.subString(2)
        }
    }
    foreach($excludePath in $excludePathsToProcess){
       if($excludePath.subString(1,1) -eq ':'){
            $excludePath = "/$($excludePath.replace(':','').replace('\','/'))".replace('//','/')
       }
       $excludePathsProcessed += $excludePath
    }
    
    # process include paths
    $includePathsProcessed = @()
    if($allDrives){
        if($cluster.clusterSoftwareVersion -gt '6.5.1b'){
            $includePathsProcessed += '$ALL_LOCAL_DRIVES'
        }else{
            foreach($mountPoint in $mountPoints){
                $includePathsProcessed += "/$($mountPoint.replace(':','').replace('\','/'))/".replace('//','/')
            }
        }
    }else{
        foreach($includePath in $includePathsToProcess){
            $includePathsProcessed += "/$($includePath.replace(':','').replace('\','/'))".replace('//','/')
        }
    }

    foreach($includePath in $includePathsProcessed){
        $newFilePath= @{
            "backupFilePath" = $includePath;
            "skipNestedVolumes" = $skip;
            "excludedFilePaths" = @()
        }
        foreach($excludePath in $excludePathsProcessed){
            if($excludePath -match $includePath -or $includePath -eq '$ALL_LOCAL_DRIVES' -or $excludePath[0] -ne '/'){
                $newFilePath.excludedFilePaths += $excludePath
            }
        }
        $newParam.physicalSpecialParameters.filePaths += $newFilePath
    }
    $newParams += $newParam
}

# update job
$job.sourceSpecialParameters = $newParams
$job.sourceIds = @($sourceIds)
$null = api put "protectionJobs/$($job.id)" $job
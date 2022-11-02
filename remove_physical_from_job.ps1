﻿# process commandline arguments	
	[CmdletBinding()]
	param (
	[Parameter(Mandatory = $True)][string]$vip, # the cluster to connect to (DNS name or IP)
	[Parameter(Mandatory = $True)][string]$username, # username (local or AD)
	[Parameter()][string]$domain = 'local',
	[Parameter()][array]$servername = '',
	[Parameter()][string]$serverlist = ''
	)
	
	# source the cohesity-api helper code
	. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)
	
	# authenticate
	apiauth -vip $vip -username $username -domain $domain
	
	# gather server names
	$servers = @()
if ('' -ne $serverList){
	if(Test-Path $serverlist -PathType Leaf){
	$servers += Get-Content $serverlist | Where-Object {$_ -ne ''}
	}elseif($serverList){
	Write-Warning "File $serverlist not found!"
	exit 1
	}
}
	if($servername){
	$servers += $servername
	}
	if($servers.Length -eq 0){
	Write-Host "No servers selected"
	exit 1
	}
	
	$sources = api get protectionSources?environments=kPhysical
	$jobs = api get protectionJobs?environments=kPhysicalFiles
	
	foreach($job in $jobs){
	$saveJob = $false
	foreach($server in $servers){
	$serverSource = $sources[0].nodes | Where-Object {$_.protectionSource.name -eq $server}
	if($serverSource){
	$serverId = $serverSource.protectionSource.id
	if($serverId -in $job.sourceIds){
	"Removing {0} from job {1}" -f $server, $job.name
	$job.sourceIds = @($job.sourceIds | Where-Object {$_ -ne $serverId})
	$job.sourceSpecialParameters = @($job.sourceSpecialParameters | Where-Object {$_.sourceId -ne $serverId })
	$saveJob = $True
	}
	}
	}
	if($saveJob){
	if($job.sourceIds.Length -gt 0){
	$null = api put protectionJobs/$($job.id) $job
	}else{
	$null = api delete protectionJobs/$($job.id)
	}
	}
	}

## does not support SQL job ###
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][ValidateSet('MiB','GiB','TiB')][string]$unit = 'GiB',
    [Parameter()][switch]$localOnly,
    [Parameter(Mandatory = $True)][string]$smtpServer, #outbound smtp server '192.168.1.95'
    [Parameter()][string]$smtpPort = 25, #outbound smtp port
   [Parameter(Mandatory = $True)][array]$sendTo, #send to address
   [Parameter(Mandatory = $True)][string]$sendFrom #send from address
)

### source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

$dateString = (get-date).ToString("yyyy-MM-dd")
#$outfileName = "$clusterName-FETB-$dateString.csv"

$environments = @('kUnknown', 'kVMware', 'kHyperV', 'kSQL', 'kView', 'kPuppeteer', 
                  'kPhysical', 'kPure', 'kAzure', 'kNetapp', 'kAgent', 'kGenericNas', 
                  'kAcropolis', 'kPhysicalFiles', 'kIsilon', 'kKVM', 'kAWS', 'kExchange', 
                  'kHyperVVSS', 'kOracle', 'kGCP', 'kFlashBlade', 'kAWSNative', 'kVCD',
                  'kO365', 'kO365Outlook', 'kHyperFlex', 'kGCPNative', 'kAzureNative',
                  'kAD', 'kAWSSnapshotManager', 'kUnknown', 'kUnknown', 'kUnknown', 'kUnknown')

$nasEnvironments = @('kNetapp', 'kIsilon', 'kGenericNas', 'kFlashBlade', 'kGPFS', 'kElastifile')

$serverEnvironments = @('kUnknown', 'kVMware', 'kHyperV', 'kPhysical', 'kAcropolis', 'kPhysicalFiles', 
                        'kKVM', 'kAWS', 'kHyperVVSS', 'kGCP', 'kAWSNative', 'kVCD',
                        'kGCPNative', 'kAzureNative', 'kAD')

$conversion = @{'MiB' = 1024 * 1024; 'GiB' = 1024 * 1024 * 1024; 'TiB' = 1024 * 1024 * 1024 * 1024}
function toUnits($val){
    return "{0:n2}" -f ($val/($conversion[$unit]))
}

#"Job Name,Object Name,Object Type,Logical Size ($unit)" | Out-File -FilePath $outfileName

### create excel spreadsheet
$xlsx = Join-Path -Path (Get-Location).Path -ChildPath "CohesityFETB_Report-$(get-date -UFormat '%Y-%m-%d-%H-%M-%S').xlsx"
write-host "Saving Report to $xlsx..."
$excel = New-Object -ComObject excel.application
$workbook = $excel.Workbooks.Add()
$worksheets=$workbook.worksheets
$sheet=$worksheets.item(1)
$sheet.activate | Out-Null
$rownum = 2
### Column Headings
$sheet.Cells.Item(1,1) = 'Cohesity Cluster'
$sheet.Cells.Item(1,2) = 'Job Name'
$sheet.Cells.Item(1,3) = 'Server Name'
$sheet.Cells.Item(1,4) = 'Backup Type'
$sheet.Cells.Item(1,5) = 'Front End sige in GB'

#$clusters = ('hcohesity01')
$clusters = ('hcohesity01','hcohesity03','hcohesity04','hcohesity05')

foreach ($vip in $clusters){

### authenticate
apiauth -vip $vip -username $username -domain corpads.local

$cluster = api get cluster
$clusterName = $cluster.name
$clusterId = $cluster.id

$uniqueBytesTable = @{}
# gather unique capacity for servers
$serverReport = api get /reports/objects/storage?msecsBeforeEndTime=0
foreach($server in $serverReport | Sort-Object -Property jobName, name){
    $serverName = $server.name
    if($server.PSObject.Properties['dataPoints']){
        $uniqueBytes = $server.dataPoints[0].primaryPhysicalSizeBytes
        if($uniqueBytes -gt 0){
            $uniqueBytesTable[$serverName] = $uniqueBytes
        }
    }
}

$jobs = api get protectionJobs?includeLastRunAndStats=true | Where-Object{$_.isDeleted -ne $True} | Sort-Object -Property name
if($localOnly){
    $jobs = $jobs | Where-Object {$_.policyId.split(':')[0] -eq $clusterId}
}

# gather capacity for Servers
foreach($job in $jobs | Where-Object {$_.environment -in $serverEnvironments}){
    $jobName = $job.name
    $jobId = $job.id
    $jobUrl = "https://$clustername/protection/job/$jobId/details"
    $jobType = $job.environment.Substring(1)
    foreach($server in $job.lastRun.backupRun.sourceBackupStatus){
        $serverName = $server.source.name
        $logicalBytes = $server.stats.totalLogicalBackupSizeBytes
        if($serverName -in $uniqueBytesTable.Keys){
            $uniqueBytes = $uniqueBytesTable[$serverName]
        }else{
            $uniqueBytes = $logicalBytes
        }
        
        #"{0},{1},{2},""{3}""" -f $jobName, $serverName, $jobType, (toUnits $logicalBytes) | Tee-Object -FilePath $outfileName -Append    
        $sheet.Cells.Item($rownum,1) = $clustername
        $sheet.Cells.Item($rownum,2) = $jobname
        $sheet.Cells.Item($rownum,3) = $serverName
        $sheet.Cells.Item($rownum,4) = $jobtype
        $sheet.Cells.Item($rownum,5) = (toUnits $logicalBytes)
        $sheet.Hyperlinks.Add(
            $sheet.Cells.Item($rownum,2),
            $jobUrl
        ) | Out-Null
        $rownum += 1
        
    }
}

# gather capacity for NAS backups
foreach($job in $jobs | Where-Object {$_.environment -in $nasEnvironments}){
    $jobName = $job.name
    $jobId = $job.id
    $jobUrl = "https://$clustername/protection/job/$jobId/details"
    $jobType = $job.environment.Substring(1)
    foreach($volume in $job.lastRun.backupRun.sourceBackupStatus){
        $volumeName = $volume.source.name
        $logicalBytes = $volume.stats.totalLogicalBackupSizeBytes
       # "{0},{1},{2},""{3}""" -f $jobName, $volumeName, $jobType, (toUnits $logicalBytes) | Tee-Object -FilePath $outfileName -Append 
        $sheet.Cells.Item($rownum,1) = $Clustername
        $sheet.Cells.Item($rownum,2) = $jobname
        $sheet.Cells.Item($rownum,3) = $volumeName
        $sheet.Cells.Item($rownum,4) = $jobtype
        $sheet.Cells.Item($rownum,5) = (toUnits $logicalBytes)
        $sheet.Hyperlinks.Add(
            $sheet.Cells.Item($rownum,2),
            $jobUrl
        ) | Out-Null
        $rownum += 1   
    }
}

# gather capacity for views
$views = api get views
foreach($view in $views.views | Sort-Object -Property name){
    $viewName = $view.name
        $logicalBytes = $view.logicalUsageBytes
    if($view.PSObject.Properties['viewProtection']){
        $jobName = $view.viewProtection.protectionJobs[0].jobName
    }else{
        $jobName = '-'
    }
    #"{0},{1},{2},""{3}""" -f $jobName, $viewName, 'View', (toUnits $logicalBytes) | Tee-Object -FilePath $outfileName -Append
    $sheet.Cells.Item($rownum,1) = $Clustername
        $sheet.Cells.Item($rownum,2) = $jobname
        $sheet.Cells.Item($rownum,3) = $viewName
        $sheet.Cells.Item($rownum,4) = 'View'
        $sheet.Cells.Item($rownum,5) = (toUnits $logicalBytes)
        $rownum += 1
}
}

### final formatting and save
$sheet.columns.autofit() | Out-Null
$sheet.columns("Q").columnWidth = 100
$sheet.columns("Q").wraptext = $True
$sheet.usedRange.rows(1).Font.Bold = $True
$excel.Visible = $true
$workbook.SaveAs($xlsx,51) | Out-Null
$workbook.close($false)
$excel.Quit()

Get-Process excel | Stop-Process -Force
# send email report
#write-host "sending report to $([string]::Join(", ", $sendTo))"
foreach($toaddr in $sendTo){
   Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Cohesity FETB report" -BodyAsHtml "Thank You"  -WarningAction SilentlyContinue -Attachments $xlsx }
#$html | out-file "$($cluster.name)-objectreport.html"
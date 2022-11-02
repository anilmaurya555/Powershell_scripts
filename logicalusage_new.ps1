[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip, # Cohesity cluster to connect to
    [Parameter(Mandatory = $True)][string]$username, #cohesity username
    [Parameter()][string]$domain = 'local', # local or AD domain
    [Parameter()][int]$days = 31,
    [Parameter()][switch]$localOnly
    #[Parameter()][string]$smtpServer, # outbound smtp server '192.168.1.95'
    #[Parameter()][string]$smtpPort = 25, # outbound smtp port
    #[Parameter()][array]$sendTo, # send to address
    #[Parameter()][string]$sendFrom # send from address
)

# source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

# authenticate
apiauth -vip $vip -username $username -domain $domain

$cluster = api get cluster

$today = get-date
$date = $today.ToString()

$title = "Logical Storage Report for $($cluster.name)"

$html = '<html>
<head>
    <style>
        p {
            color: #555555;
            font-family:Arial, Helvetica, sans-serif;
        }
        span {
            color: #555555;
            font-family:Arial, Helvetica, sans-serif;
        }
        

        table {
            font-family: Arial, Helvetica, sans-serif;
            color: #333333;
            font-size: 0.75em;
            border-collapse: collapse;
            width: 100%;
        }

        tr {
            border: 1px solid #F1F1F1;
        }

        td,
        th {
            width: 20%;
            text-align: left;
            padding: 6px;
        }

        tr:nth-child(even) {
            background-color: #F1F1F1;
        }
    </style>
</head>
<body>
    
    <div style="margin:15px;">
            <img src="https://www.cohesity.com/wp-content/themes/cohesity/refresh_2018/templates/dist/images/footer/footer-logo-green.png" style="width:180px">
        <p style="margin-top: 15px; margin-bottom: 15px;">
            <span style="font-size:1.3em;">'

$html += $title
$html += '</span>
<span style="font-size:0.75em; text-align: right; padding-top: 8px; padding-right: 2px; float: right;">'
$html += $date
$html += '</span>
</p>
<table>
<tr>
        <th>Server Name</th>
        <th>Size</th>
        <th>Enviornment</th>
        
      </tr>'

$report = @{}

##############

"Inspecting snapshots..."
foreach ($job in (api get protectionJobs?allUnderHierarchy=true)){
    if(!($localOnly -and $job.IsActive -eq $False)){
        $runs = api get protectionRuns?jobId=$($job.id)`&numRuns=99999`&excludeNonRestoreableRuns=true`&runTypes=kFull`&runTypes=kRegular`&startTimeUsecs=$(timeAgo $days days)
        foreach ($run in $runs){
            if ($run.backupRun.snapshotsDeleted -eq $false) {
                foreach($source in $run.backupRun.sourceBackupStatus){
                    $sourcename = $source.source.name
                    if($sourcename -notin $report.Keys){
                        $report[$sourcename] = @{}
                        $report[$sourcename]['size'] = 0
                        $report[$sourcename]['environment'] = $source.source.environment
                    }
                    if($source.stats.totalLogicalBackupSizeBytes -gt $report[$sourcename]['size']){
                        $report[$sourcename]['size'] = $source.stats.totalLogicalBackupSizeBytes
                    }
                }
            }
        }
        ###
    }
    ###
}                                                                                           

"Inspecting Views..."
if($localOnly){
    $views = api get views?allUnderHierarchy=true
}else{
    $views = api get views?includeInactive=true
}
foreach($view in $views.views){
    $viewname = $view.name
    if($view.name -notin $report.Keys){
        $report[$viewname] = @{}
        $report[$viewname]['size'] = $view.logicalUsageBytes
        $report[$viewname]['environment'] = 'kView'
    }
}

$total = 0

"`n{0,15}  {1,10:n0}  {2}" -f ('Environment', 'Size (GB)', 'Name')
"{0,15}  {1,10:n0}  {2}" -f ('===========', '=========', '====')
#"Environment,Size(GB),Name" | Out-File -FilePath $outFile

$report.GetEnumerator() | Sort-Object -Property {$_.Value.size} -Descending | ForEach-Object {
     $environment = $_.Value.environment
     $size = [math]::Round(($_.Value.size/(1024*1024*1024)),2)
     $viewname = $_.Name
     $html += "<tr>
        <td>$viewname</td>
        <td>$size</td>
        <td>$environment</td>
        </tr>"
     $total += $_.Value.size
}
"`n    Total Logical Size: {0:n0} GB`n" -f ($total/(1024*1024*1024))
#$html += td "Total Logical Size: {0:n0} GB`n" -f ($total/(1024*1024*1024)) '''CENTER'

$html += "</table>                
</div>
</body>
</html>"

$fileDate = $date.Replace('/','-').Replace(':','-').Replace(' ','_')
$html | Out-File -FilePath "storageReport_$($cluster.name)_$fileDate.html"

Write-Host "`nsaving report as storageReport_$($cluster.name)_$fileDate.html"

#if($smtpServer -and $sendTo -and $sendFrom){
   # Write-Host "`nsending report to $([string]::Join(", ", $sendTo))`n"

    # send email report
    #foreach($toaddr in $sendTo){
     #   Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject $title -BodyAsHtml $html -WarningAction SilentlyContinue
    #}
#}
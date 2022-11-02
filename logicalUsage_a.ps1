### usage: ./logicalUsage.ps1 -vip mycluster -username myusername [ -domain mydomain.net ] [ -days 90 ]

### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][string]$domain = 'local',
    [Parameter()][int]$days = 14,
    [Parameter()][switch]$localOnly
)

### source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

### authenticate
apiauth -vip $vip -username $username -domain $domain

$cluster = api get cluster
$outFile = Join-Path -Path $PSScriptRoot -ChildPath "logicalUsage-$($cluster.name).csv"

$report = @{}
$today = Get-Date
$lastwdate = dateToUsecs $today
$lastmdate = dateToUsecs ($today.Date.AddDays(-31))

# HTML HEAD
function tdhead($data, $color){
    '<td colspan="1" bgcolor="#' + $color + '" valign="top" align="CENTER" border="0"><font size="2">' + $data + '</font></td>'
}
function td($data, $color, $wrap='', $align='LEFT'){
    '<td ' + $wrap + ' colspan="1" bgcolor="#' + $color + '" valign="top" align="' + $align + '" border="0"><font size="2">' + $data + '</font></td>'
}

$html = '<html>'

$html += '<div style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;"><font face="Tahoma" size="+3" color="#000080">
<hr>

<br><br></div>'

$html += '<table align="center" border="1" cellpadding="4" cellspacing="0" style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;">
<tbody><tr><td colspan="21" align="CENTER" valign="TOP" bgcolor="#000080"><font size="+1" color="#FFFFFF">Logical space usage</font></td></tr><tr bgcolor="#FFFFFF">'

$headings = @('Object Name',
              'Size (GB)', 
              'Enviornment')
              
foreach($heading in $headings){
    $html += td $heading 'CCCCCC' '' 'CENTER'
}
$html += '</tr>'
$nowrap = 'nowrap'
# HTML head stops

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
                        $report[$sourcename]['size1'] = 0
                        $report[$sourcename]['environment'] = $source.source.environment
                    }
                    if ($sourcename -eq 'server-b-win13.its4u.com') {
                    "{0}`t{1}`t{2}" -f (usecsToDate $run.backupRun.stats.startTimeUsecs), $sourcename,[math]::Round(($source.stats.totalLogicalBackupSizeBytes/(1024*1024*1024)),2) 
                        }
                        if($source.stats.totalLogicalBackupSizeBytes -gt $report[$sourcename]['size1']){
                        $report[$sourcename]['size1'] = $source.stats.totalLogicalBackupSizeBytes
                                            
                    }
                    
                }

            }
        }
    }
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
        $report[$viewname]['size1'] = $view.logicalUsageBytes
        $report[$viewname]['environment'] = 'kView'
    }
                              
}

$total = 0

"`n{0,15}  {1,10:n0}  {2}" -f ('Environment', 'Current Size (GB)', 'Name')
"{0,15}  {1,10:n0}  {2}" -f ('===========', '=========', '====')
"Environment,Size(GB),Name" | Out-File -FilePath $outFile

$report.GetEnumerator() | Sort-Object -Property {$_.Value.size1} -Descending | ForEach-Object {
    "{0,15}  {1,10:n0}  {2}" -f ($_.Value.environment, [math]::Round(($_.Value.size1/(1024*1024*1024)),2), $_.Name)
    "{0},{1},{2}" -f ($_.Value.environment, [math]::Round(($_.Value.size1/(1024*1024*1024)),2), $_.Name) | Out-File -FilePath $outFile -Append
                            $newsize = [math]::Round(($_.Value.size1/(1024*1024*1024)),2)
                            $html += ("<td>{0}</td>
                              <td>{1}</td>
                              <td>{2}</td>
                               </tr>" -f $_.name, $newsize, $_.Value.environment)

    $total += $_.Value.size1
}
"`n    Total Logical Size: {0:n0} GB`n" -f ($total/(1024*1024*1024))
$html += "</table>                
</div>
</body>
</html>"


$html | Out-File -FilePath html2.html
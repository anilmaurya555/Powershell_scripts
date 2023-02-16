### usage: ./monitorReplicationTasks.ps1 -vip mycluster -username admin [ -domain local ]

### process commandline arguments
[CmdletBinding()]
param (
    #[Parameter(Mandatory = $True)][string]$vip, #the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username, #username (local or AD)
    [Parameter()][string]$domain = 'ent.ad.ntrs.com', #local or AD domain
    [Parameter()][string]$jobname  , ## if not given will list all jobs
    [Parameter()][string]$jobPrefix  , ## if given job name's prefix
    [Parameter()][switch]$alljobs  , ## if given job name's prefix
    [Parameter()][string]$remotecluster  , ## only look for this remote cluster
    [Parameter()][Int64]$daysBack = 7,
    [Parameter()][Int64]$numRuns = 9999,
    [Parameter()][switch]$lastOnly, # will collect last run only
    [Parameter()][string]$smtpServer, # outbound smtp server '192.168.1.95'
    [Parameter()][string]$smtpPort = 25, # outbound smtp port
    [Parameter()][array]$sendTo, # send to address
   [Parameter()][string]$sendFrom, # send from address
    [Parameter()][switch]$runningOnly
)

### source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

### create excel spreadsheet
$xlsx = Join-Path -Path (Get-Location).Path -ChildPath "Daily_Vault_replication_stats_$(get-date -UFormat '%Y-%m-%d-%H-%M-%S').xlsx"
write-host "Saving Report to $xlsx..."
$excel = New-Object -ComObject excel.application
$workbook = $excel.Workbooks.Add()
$worksheets=$workbook.worksheets
$sheet=$worksheets.item(1)
$sheet.activate | Out-Null

### Column Headings
$sheet.Cells.Item(1,1) = 'Cohesity Cluster'
$sheet.Cells.Item(1,2) = 'Group Nmae'
$sheet.Cells.Item(1,3) = 'Cluster Name'
$sheet.Cells.Item(1,4) = 'Status'

$sheet.usedRange.rows(1).font.colorIndex = 10
$sheet.usedRange.rows(1).font.bold = $True
$rownum = 2

#$vips = ('chyusnpccp01','chyusnpccp02')
$vips = ('chyusnpccp02','chyuswpccp02','chyusnpccp03','chyuswpccp03','chyusnpccp05','chyuswpccp05')
$allfiles = @()

foreach ($vip in $vips){

#################HTML#############
$html = '<html>
<head>
    <style>
                h1 {
            background-color:#b1ffb1;
            }
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
            width: 33%;
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
            <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAARgAAAAoCAMAAAASXRWnAAAC8VBMVE
            WXyTz///+XyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyTyXyT
            yXyTyXyTyXyTyXyTwJ0VJ2AAAA+nRSTlMAAAECAwQFBgcICQoLDA0ODxARExQVFhcYGRobHB0eHy
            EiIyQlJicoKSorLC0uLzAxMjM0NTY3ODk6Ozw9Pj9AQUNERUZHSElKS0xNTk9QUVJTVFVWV1hZWl
            tcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9foCBgoOEhYaHiImKi4yNjo+QkZKTlJ
            WWl5iZmpucnZ6foKGio6SlpqeoqaqrrK2ur7CxsrO0tba3uLm6u7y9vr/AwcLDxMXGx8jJysvMzc
            7Q0dLT1NXW19jZ2tvc3d7f4OHi4+Xm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+drbbjAAACOZJRE
            FUaIHtWmlcVUUUv6alIgpiEGiZZIpiKu2i4obhUgipmGuihuZWiYmkRBu4JJVappaG5VJRUWrllq
            ZWivtWVuIWllHwShRI51PvnjP33pk7M1d579Gn/j8+zDnnf2b5v3tnu2g1/ocUmvuPRasx83cVu1
            zFB5endtWUCHgoM/+0y1V64sOZcXVlhMDpWXdLM+PmPnmdZTVJeLCPiL6Jd9jT6nfo2y+hH4vE/h
            Fcj6bP6uhcqxvxfYzOdsxOb6gYm39qdrRmE6bBxB2EQWHOXfLBvVvMsIqWdBEYzYvcgWRJ6nS3f5
            +/YSWXEQVeYJPqpXx5XkaaalFuOu22h2E5UVkrIadaAyXFXTwbKh1cw0J3bCgvzFO/CRWtuk3IjP
            lKYK23C7ga3IFCblPwp1HrNvUAyH1W0tRzKlIbk/OmbpbX04uNHGp1/9j6MxMMxUNSYXbqoTJWmF
            t3yCqqHGVLzJK2l8qTtoOzldBqD/C/Ra3hDgOYZKTU2awmpZgVbwG7udWGEvovHYXFHIkuYzHECN
            Pzb0VNy9g8/60KVh5X/QbwtRCajQH//GsQ5k7KCTzqQGprVrwW7HC9GOKQQMhpP30UpWiIM0XYZQ
            gcsYR50Mo9vj73vS9+sOy1Vl6A5S7auXJ53v4Lpr2Trf9LcN0utNsZ/K9Ra4iy++XGE+h3zGGQaV
            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
            8LK0YAAAAASUVORK5CYII=" style="width:180px">
        <p style="margin-top: 15px; margin-bottom: 15px;">
            <span style="font-size:1.3em;">'

$html += '</span>
                </p>
                <table style="width:40%">
                <tr style=padding-left: 5px; font-size:15px>
                        <th>Cluster Name</th>
                        <th>Group Nmae</th>
                        <th>Remote Cluster</th>
                        <th>Status</th>
                        </tr>'
###### HTML for cluster name ########
$html += "
                                                 <td style='padding-left: 5px; font-size:15px; color:#32B232'>$vip</td>
                                                 <td></td>
                                                 <td></td>
                                                 <td></td>
                                                 </tr>"

### authenticate
apiauth -vip $vip -username $username -domain $domain

$policies = api get protectionPolicies |Where-Object {($_.snapshotReplicationCopyPolicies).count -gt 0}

### find protectionRuns with active replication tasks
$daysBackUsecs = dateToUsecs ((Get-Date).AddDays(-$daysBack))
$finishedStates = @('Canceled', 'Succeeded', 'Failed')
$foundOne = $false
if($lastOnly){
    $numRuns = 1
}

<#"`nLooking for Replication Tasks...`n"
"Job Name,Run Date,Target,Status,Replication Start,Replication End" | Out-File -FilePath $outFile#>

foreach ($job in (api get -v2 data-protect/protection-groups?isActive=true).protectionGroups |where-object { $_.isdeleted -ne $True -and $_.isPaused -ne $True -and $policies.id -contains $_.policyId}| Sort-Object -Property name){
    
    $jobName = $job.name
    #"  $jobName $($job.id) "
    ##########HTML tagging for job name #####

   if(!$remotecluster ){  $html += "
                                                 <td></td>
                                                 <td>$jobName</td>
                                                 <td></td>
                                                 <td></td>
                                                 </tr>"
                                                 }
    foreach($run in (api get -v2 "data-protect/protection-groups/$($job.id)/runs?startTimeUsecs=$daysBackUsecs&numRuns=$numRuns&includeTenants=true&includeObjectDetails=false").runs){
        $runDate = usecsToDate $run.localBackupInfo.startTimeUsecs
        if($run.PSObject.Properties['replicationInfo']){
            foreach($replication in $run.replicationInfo.replicationTargetResults){
                $target = $replication.clusterName
                $status = $replication.status
                $replicationStart = '-'
                $replicationEnd = '-'
                if($replication.PSObject.Properties['startTimeUsecs']){
                    $replicationStart = usecsToDate $replication.startTimeUsecs
                }
                if($replication.PSObject.Properties['endTimeUsecs']){
                    $replicationEnd = usecsToDate $replication.endTimeUsecs
                }
                if(!$runningOnly -or $status -notin $finishedStates){
                    $foundOne = $True
                    Write-Host "      $runDate -> $target ($status)"
                    #"$jobName,$runDate,$target,$status,$replicationStart,$replicationEnd" | Out-File -FilePath $outFile -Append
                    ########### HTML tag for replication status
                                  if ($remotecluster -eq $target){
                                  $html += "
                                                 <td></td>
                                                 <td>$jobName</td>
                                                 <td></td>
                                                 <td></td>
                                                 </tr>"
                    $html += "
                                                 <td></td>
                                                 <td></td>
                                                 <td>$target </td>
                                                 <td>$status</td>
                                                 </tr>"

                                                 ####### populate Excel sheet
                                                if($job.isActive -ne $false ){  #3
                                                        $sheet.Cells.Item($rownum,1) = $vip
                                                        $sheet.Cells.Item($rownum,2) = $jobName
                                                        $sheet.Cells.Item($rownum,3) = $target
                                                        $sheet.Cells.Item($rownum,4) = $status
                                                        
                                                        $rownum += 1
                                                    }   #3
                                                    ################end of excel sheet population

                                                 }
                                                 if(!$remotecluster){
                                                 $html += "
                                                 <td></td>
                                                 <td></td>
                                                 <td>$target </td>
                                                 <td>$status</td>
                                                 </tr>"
                                                 if($job.isActive -ne $false ){  #3
                                                        $sheet.Cells.Item($rownum,1) = $vip
                                                        $sheet.Cells.Item($rownum,2) = $jobName
                                                        $sheet.Cells.Item($rownum,3) = $target
                                                        $sheet.Cells.Item($rownum,4) = $status
                                                        
                                                        $rownum += 1
                                                    }   #3
                                                    ################end of excel sheet population
                                                 
                                                 }
                                                 
                }  
            }
        }
    }
}
         
if($false -eq $foundOne){
    write-host "`nNo replication tasks found`n"
}else{
    Write-Host "`nOutput saved to $outFile`n"
}
$html += "</table>                
</div>
</body>
</html>"


#$fileDate = $date.Replace('/','-').Replace(':','-').Replace(' ','_')
$outfilepath = "$($vip)_to_CHYUSAGVCP99.html"
$html | Out-File -FilePath $outfilepath
Write-Host "`nsaving report as Daily_replication_stats_from_$($vip)_to_CHYUSAGVCP99.html"
$allfiles += $outfilepath
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

#############html 2 ######
$title2 = "Thank you "
$html2 = '<html>
<body>
    <div style="margin:15px;">
            
        <p style="margin-top: 15px; margin-bottom: 15px;">
            <span style="font-size:1.3em;">'

$html2 += '</table>
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;color: #0000FF"> Attached report also availbe on NAS share : \\cohwpcu01.ent.ad.ntrs.com\cohesity_reports </span></span></p>
</html>'
$html2 += $title2

##############

if($smtpServer -and $sendTo -and $sendFrom){
    Write-Host "`nsending report to $([string]::Join(", ", $sendTo))`n"

    # send email report
   foreach($toaddr in $sendTo){
        Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Daily replication stats to Vault." -BodyAsHtml $html2 -WarningAction SilentlyContinue -Attachments $xlsx
    }
}
#copy report to NAS share
$today = Get-Date
$targetPath = '\\cohwpcu01.ent.ad.ntrs.com\cohesity_reports'
$year = $today.Year.ToString()
$month = $today.Month.ToString()
$date  =  $today.date.ToString('MM-dd') 
# Set Directory Path
$Directory = $targetPath + "\" + $year + "\" + $month + "\" + $date
# Create directory if it doesn't exsist
if (!(Test-Path $Directory))
{
New-Item $directory -type directory
}
# copy File to NAS location
foreach ($file in $allfiles){
$file | Copy-Item -Destination $Directory}
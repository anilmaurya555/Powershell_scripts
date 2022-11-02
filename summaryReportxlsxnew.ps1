### Usage: ./summaryReportXLSX.ps1 -vip mycluster -username myuser -domain mydomain.net

### process commandline arguments
[CmdletBinding()]
param (
    
    [Parameter(Mandatory = $True)][string]$username,
   
    [Parameter()][string]$smtpServer, #outbound smtp server '192.168.1.95'
    [Parameter()][string]$smtpPort = 25, #outbound smtp port
   [Parameter()][array]$sendTo, #send to address
   [Parameter()][string]$sendFrom #send from address
)
$today = Get-Date
### source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)
##################
 # process email body
 $title = "Thank you "
$html = '<html>
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

$html += '</table>
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;color: #0000FF"> Attached report also availbe on NAS share : \\hcohesity05\cohesity_reports </span></span></p>
</html>'
$html += $title
# process email body end
 

### create excel spreadsheet
$xlsx = Join-Path -Path (Get-Location).Path -ChildPath "Cohesity_complete_list-$(get-date -UFormat '%Y-%m-%d-%H-%M-%S').xlsx"
write-host "Saving Report to $xlsx..."
$excel = New-Object -ComObject excel.application
$workbook = $excel.Workbooks.Add()
$worksheets=$workbook.worksheets
$sheet=$worksheets.item(1)
$sheet.activate | Out-Null

### Column Headings
$sheet.Cells.Item(1,1) = 'Cohesity Cluster'
$sheet.Cells.Item(1,2) = 'Protection Object Type'
$sheet.Cells.Item(1,3) = 'Protection Object Name'
$sheet.Cells.Item(1,4) = 'Registered Source Name'
$sheet.Cells.Item(1,5) = 'Protection Job Name'
$sheet.Cells.Item(1,6) = 'Num Snapshots'
$sheet.Cells.Item(1,7) = 'Last Run Status'
$sheet.Cells.Item(1,8) = 'Schedule Type'
$sheet.Cells.Item(1,9) = 'Last Run Start Time'
$sheet.Cells.Item(1,10) = 'End Time'
$sheet.Cells.Item(1,11) = 'First Successful Snapshot'
$sheet.Cells.Item(1,12) = 'First Failed Snapshot'
$sheet.Cells.Item(1,13) = 'Last Successful Snapshot'
$sheet.Cells.Item(1,14) = 'Last Failed Snapshot'
$sheet.Cells.Item(1,15) = 'Num Errors'
$sheet.Cells.Item(1,16) = 'Data Read'
$sheet.Cells.Item(1,17) = 'Logical Protected'
$sheet.Cells.Item(1,18) = 'Last Error Message'  

$clusters = ('Hcohesity01')
#$clusters = ('Hcohesity01','Hcohesity03','Hcohesity04','Hcohesity05')

### populate data
$rownum = 2
foreach ( $cluster in $clusters){


### authenticate
apiauth -vip $cluster -username $username -domain corpads.local

### get jobs
$jobs = api get protectionJobs

### get report
$report = api get 'reports/protectionSourcesJobsSummary?allUnderHierarchy=true'

foreach($source in ($report.protectionSourcesJobsSummary|Where-Object {$_.jobname -notlike "*DELETED*" })){
    $type = $source.protectionSource.environment.Substring(1)
    $name = $source.protectionSource.name
    $parentName = $source.registeredSource
    $jobName = $source.jobName
    $job = $jobs | Where-Object {$_.name -eq $jobName}
    $jobId = $job.id
    $jobUrl = "https://$cluster/protection/job/$jobId/details"
    $numSnapshots = $source.numSnapshots
    $lastRunStatus = $source.lastRunStatus.Substring(1)
    $lastRunType = $source.lastRunType
    $lastRunStartTime = usecsToDate $source.lastRunStartTimeUsecs
    $lastRunEndTime = usecsToDate $source.lastRunEndTimeUsecs
    $firstSuccessfulRunTime = usecsToDate $source.firstSuccessfulRunTimeUsecs
    $lastSuccessfulRunTime = usecsToDate $source.lastSuccessfulRunTimeUsecs
    if($lastRunStatus -eq 'Error'){
        $lastRunErrorMsg = $source.lastRunErrorMsg.replace("`r`n"," ").split('.')[0]
        $firstFailedRunTime = usecsToDate $source.firstFailedRunTimeUsecs
        $lastFailedRunTime = usecsToDate $source.lastFailedRunTimeUsecs
    }else{
        $lastRunErrorMsg = ''
        $firstFailedRunTime = ''
        $lastFailedRunTime = ''
    }
    $numDataReadBytes = $source.numDataReadBytes
    $numDataReadBytes = $numDataReadBytes/$numSnapshots
    if($numDataReadBytes -lt 1000){
        $numDataReadBytes = "$numDataReadBytes B"
    }elseif ($numDataReadBytes -lt 1000000) {
        $numDataReadBytes = "$([math]::Round($numDataReadBytes/1024, 2)) KiB"
    }elseif ($numDataReadBytes -lt 1000000000) {
        $numDataReadBytes = "$([math]::Round($numDataReadBytes/(1024*1024), 2)) MiB"
    }elseif ($numDataReadBytes -lt 1000000000000) {
        $numDataReadBytes = "$([math]::Round($numDataReadBytes/(1024*1024*1024), 2)) GiB"
    }else{
        $numDataReadBytes = "$([math]::Round($numDataReadBytes/(1024*1024*1024*1024), 2)) TiB"
    }
    $numLogicalBytesProtected = $source.numLogicalBytesProtected/$numSnapshots
    if($numLogicalBytesProtected -lt 1000){
        $numLogicalBytesProtected = "$numLogicalBytesProtected B"
    }elseif ($numLogicalBytesProtected -lt 1000000) {
        $numLogicalBytesProtected = "$([math]::Round($numLogicalBytesProtected/1024, 2)) KiB"
    }elseif ($numLogicalBytesProtected -lt 1000000000) {
        $numLogicalBytesProtected = "$([math]::Round($numLogicalBytesProtected/(1024*1024), 2)) MiB"
    }elseif ($numLogicalBytesProtected -lt 1000000000000) {
        $numLogicalBytesProtected = "$([math]::Round($numLogicalBytesProtected/(1024*1024*1024), 2)) GiB"
    }else{
        $numLogicalBytesProtected = "$([math]::Round($numLogicalBytesProtected/(1024*1024*1024*1024), 2)) TiB"
    }

    $numErrors = $source.numErrors + $source.numWarnings

    if($job.isActive -ne $false ){
        $sheet.Cells.Item($rownum,1) = $cluster
        $sheet.Cells.Item($rownum,2) = $type
        $sheet.Cells.Item($rownum,3) = $name
        $sheet.Cells.Item($rownum,4) = $parentName
        $sheet.Cells.Item($rownum,5) = $jobName
        $sheet.Cells.Item($rownum,6) = $numSnapshots
        $sheet.Cells.Item($rownum,7) = $lastRunStatus
        $sheet.Cells.Item($rownum,8) = $lastRunType
        $sheet.Cells.Item($rownum,9) = $lastRunStartTime
        $sheet.Cells.Item($rownum,10) = $lastRunEndTime
        $sheet.Cells.Item($rownum,11) = $firstSuccessfulRunTime
        $sheet.Cells.Item($rownum,12) = $firstFailedRunTime
        $sheet.Cells.Item($rownum,13) = $lastSuccessfulRunTime
        $sheet.Cells.Item($rownum,14) = $lastFailedRunTime
        $sheet.Cells.Item($rownum,15) = $numErrors
        $sheet.Cells.Item($rownum,16) = $numDataReadBytes
        $sheet.Cells.Item($rownum,17) = $numLogicalBytesProtected
        $sheet.Cells.Item($rownum,18) = $lastRunErrorMsg
        if($lastRunStatus -eq 'Warning'){
            $sheet.usedRange.rows($rownum).interior.colorIndex = 36
        }
        if($lastRunStatus -eq 'Error'){
            $sheet.usedRange.rows($rownum).interior.colorIndex = 3
            $sheet.usedRange.rows($rownum).VerticalAlignment = -4160
        }
        $sheet.Hyperlinks.Add(
            $sheet.Cells.Item($rownum,5),
            $jobUrl
        ) | Out-Null
        $rownum += 1
    }
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
   Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Cohesity Complete Backup list from ALL clusters" -BodyAsHtml $html -WarningAction SilentlyContinue -Attachments $xlsx }
#$html | out-file "$($cluster.name)-objectreport.html"
#copy report to NAS share
$targetPath = '\\hcohesity05.corpads.local\cohesity_reports'
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
$xlsx | Copy-Item -Destination $Directory
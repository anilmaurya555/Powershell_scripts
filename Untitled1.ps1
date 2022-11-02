[CmdletBinding()]

param (

    [Parameter(Mandatory = $True)][string]$vip, # Cohesity cluster to connect to

    [Parameter(Mandatory = $True)][string]$username, #cohesity username

    [Parameter()][string]$domain = 'local',  # local or AD domain

    [Parameter()][string]$timeZone = 'America/New_York',

    [Parameter()][string]$smtpServer, # outbound smtp server '192.168.1.95'

    [Parameter()][string]$smtpPort = 25, # outbound smtp port

    [Parameter()][array]$sendTo, # send to address

    [Parameter()][string]$sendFrom # send from address

)
# source the cohesity-api helper code

. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

 # authenticate

apiauth -vip $vip -username $username -domain $domain

 

$cluster = api get cluster

 

$today = get-date

$fileDate = $today.ToString('yyyy-MM-dd')

$todayUsecs = dateToUsecs (get-date -Date $today -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddMilliseconds(-1)

$lastWeek = get-date -Date $today.AddDays(-7) -Hour 0 -Minute 0 -Second 0 -Millisecond 0

$lastWeekUsecs = dateToUsecs $lastWeek

$reportDays = for ($i = $lastWeek; $i -le $today; $i=$i.AddDays(1)){$i.ToString('MM-dd')}

$reportDays = @()

$reportDates = @()

for ($i = $lastWeek; $i -le $today; $i=$i.AddDays(1)){

    $reportDays += $i.ToString('MM-dd')

    $reportDates += $i

}

 

$title = "Heatmap Report for $($cluster.name)"

 

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

            border: 0px solid #F1F1F1;

        }

        td,

        th {

            width: 6%;

            text-align: left;

            padding: 1px;

        }

        .color-block-success {

            float: left;

            background-color: #009e00;

            height: 30px;

            display: block;

        }

        .color-block-error {

            float: left;

            background-color: #f41a2e;

            height: 30px;

            display: block;

        }

        .color-block-cancelled {

            float: left;

            background-color: #ffa458;

            height: 30px;

            display: block;

        }

        .color-block-running {

            float: left;

            background-color: #7bd0ff;

            height: 30px;

            display: block;

        }

        .color-block-none {

            float: left;

            background-color: #f7f7f7;

            height: 30px;

            display: block;

            width: 100%;

        }

        .color-block-wrapper {

            height: 100%;

            width: 100%;

            display: block;

        }

    </style>

</head>

<body>
    <div style="margin:15px;">
    <img  style="width:180px">
    <p style="margin-top: 15px; margin-bottom: 15px;">
            <span style="font-size:1.3em;">'
 

$html += $title

$html += '</span>

<span style="font-size:1em; text-align: right; padding-right: 2px; float: right;">'

$html += $fileDate

$html += "</span>

</p>

<table>

<tr>

    <th>Parent</th>

    <th>Object</th>

    <th>Type</th>

    <th>{0}</th>

    <th>{1}</th>

    <th>{2}</th>

    <th>{3}</th>

    <th>{4}</th>

    <th>{5}</th>

    <th>{6}</th>

</tr>" -f $reportDays

 

$report = api get "reports/protectedObjectsTrends?allUnderHierarchy=true&endTimeUsecs=$todayUsecs&rollup=day&startTimeUsecs=$lastWeekUsecs&timezone=$timeZone"

 

"Generation Heatmap report...`n"

foreach($item in $report | Sort-Object -Property name){

    if ( $item.environment.subString(1) -like "SQL"){

    $parentName = $item.parentSourceName

    $objectName = $item.name

    "    $objectName"

    $objectType = $item.environment.subString(1)

    $trends = $item.trends

    $trendCells = @()

    foreach($reportDate in $reportDates){

        $trend = $trends | Where-Object {(get-date -Date ($_.trendName)) -eq $reportDate }

        if($trend){

            $pctSuccess = 100 * $trend.successful / $trend.total

            $pctFailed = 100 * $trend.failed / $trend.total

            $pctRunning = 100 * $trend.running / $trend.total

            $pctCancelled = 100 * $trend.cancelled / $trend.total

 

            $trendHTML = '<div class="color-block-wrapper">'

            $trendHTML += '<div class="color-block-success" style="width:' + $pctSuccess + '%;"></div>'

            $trendHTML += '<div class="color-block-error" style="width:' + $pctFailed + '%;"></div>'

            $trendHTML += '<div class="color-block-cancelled" style="width:' + $pctCancelled + '%;"></div>'

            $trendHTML += '<div class="color-block-running" style="width:' + $pctRunning + '%;"></div>'

            $trendHTML += '</div>'

 

            # $trendHTML = '<div class="color-block-wrapper"><div class="color-block-success" style="width:' + $pctSuccess + '%;"></div><div class="color-block-error" style="width:' + $pctFailed + '%;"></div><div class="color-block-cancelled" style="width:' + $pctCancelled + '%;"></div><div class="color-block-running" style="width:' + $pctRunning + '%;"></div></div>'

        }else{

            $trendHTML = '<div class="color-block-wrapper"><div class="color-block-none"></div></div>'

        }

        $trendCells += $trendHTML

    }

    $html += "<td>$parentName</td>

    <td>$objectName</td>

    <td>$objectType</td>

    <td>{0}</td>

    <td>{1}</td>

    <td>{2}</td>

    <td>{3}</td>

    <td>{4}</td>

    <td>{5}</td>

    <td>{6}</td>

    </tr>" -f $trendCells

}

}

 

$html += "</table>                

</div>

</body>

</html>"

 

$fileName = "heatmap_$($cluster.name)_$fileDate.html"

$html | Out-File -FilePath $fileName

 

Write-Host "`nsaving report as heatmap_$($cluster.name)_$fileDate.html"

 

if($smtpServer -and $sendTo -and $sendFrom){

    Write-Host "`nsending report to $([string]::Join(", ", $sendTo))`n"

 

    # send email report

    foreach($toaddr in $sendTo){

        Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject $title -BodyAsHtml $html -Attachments $fileName -WarningAction SilentlyContinue

    }

}

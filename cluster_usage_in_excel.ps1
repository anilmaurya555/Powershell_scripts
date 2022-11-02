 ### usage: ./graphStorageGrowth.ps1 -vip mycluster -username myuser [ -domain mydomain.net ] [ -days 60 ]

### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][int32]$days = 60
)

### constants
$TB = (1024*1024*1024*1024)
$GB = (1024*1024*1024)

### source the cohesity-api helper code
. ./cohesity-api
### create excel spreadsheet
$MissingType = [System.Type]::Missing
$WorksheetCount = 2
$xlsx = Join-Path -Path (Get-Location).Path -ChildPath "ClusterUsageReport-$(get-date -UFormat '%Y-%m-%d-%H-%M-%S').xlsx"
$xl = new-object -ComObject Excel.Application   
$null = $xl.Worksheets.Add($MissingType, $xl.Worksheets.Item($xl.Worksheets.Count), 
$WorksheetCount - $xl.Worksheets.Count, $xl.Worksheets.Item(1).Type)
$workbook = $xl.Workbooks.Add()
$i = 1
$clusters = ('Hcohesity01','Hcohesity03')

foreach ($vip in $clusters){
### create excel woorksheet
$worksheet = $workbook.Worksheets.Item($i)
$worksheet.Name = "$vip-Storage Growth"
$worksheet.activate()

### headings for data rows
$row = 1
$worksheet.Cells.Item($row,1) = 'Date'
$worksheet.Cells.Item($row,2) = 'Usage in Tib'
$row++



### authenticate
apiauth -vip $vip -username $username -domain corpads.local

### calculate startTimeMsecs
$startTimeMsecs = $(timeAgo $days days)/1000

### get cluster info
$clusterInfo = api get cluster?fetchStats=true
$clusterId = $clusterInfo.id

### collect $days of write throughput stats
#$stats = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kSystemUsageBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400
$stats = api get "statistics/timeSeriesStats?endTimeMsecs=1662609600000&entityId=$clusterId&metricName=kMorphedUsageBytes&metricUnitType=0&range=day&rollupFunction=average&rollupIntervalSecs=86400&schemaName=kBridgeClusterStats&startTimeMsecs=$startTimeMsecs"


### populate excel worksheet with the throughput stats 
foreach ($stat in $stats.dataPointVec){
    $day = usecsToDate (($stat.timestampMsecs)*1000)
    $consumed = $stat.data.int64Value/$TB
    $worksheet.Cells.Item($row,1) = "$day".split()[0]
    $worksheet.Cells.Item($row,2) =  "{0:N2}" -f $consumed
    $row++
}

### create excel chart
$chartData = $worksheet.Range("A1").CurrentRegion
$chart = $worksheet.Shapes.AddChart().Chart
$chart.chartType = 4
$chart.SetSourceData($chartData)
$chart.HasTitle = $true
$chart.ChartTitle.Text = "Storage Consumption Last $days Days"
$chart.Parent.Top = 50
$chart.Parent.Left = 150
$chart.Parent.Width = 600
$i++
           }
#$xl.visible = $true
#[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl)
$worksheet.columns.autofit() | Out-Null
$worksheet.usedRange.rows(1).Font.Bold = $True
$workbook.SaveAs($xlsx,51) | Out-Null

 ### usage: ./graphStorageGrowth.ps1 -vip mycluster -username myuser [ -domain mydomain.net ] [ -days 60 ]

### process commandline arguments
[CmdletBinding()]
param (
    [Parameter()][string]$smtpServer, #outbound smtp server '192.168.1.95'
    [Parameter()][string]$smtpPort = 25, #outbound smtp port
   [Parameter()][array]$sendTo, #send to address
   [Parameter()][string]$sendFrom, #send from address
    [Parameter()][string]$username,
    [Parameter()][int32]$days = 60
)

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
<p style="margin-top: 15px; margin-bottom: 15px;"><span style="font-size:1em;color: #0000FF"> Attached report also availbe on NAS share : \\cohwpcu01.ent.ad.ntrs.com\cohesity_reports </span></span></p>
</html>'
$html += $title

### constants
$TB = (1024*1024*1024*1024)
$GB = (1024*1024*1024)

### source the cohesity-api helper code
. ./cohesity-api
### create excel spreadsheet
$xlsx = Join-Path -Path (Get-Location).Path -ChildPath "Last Six Months Cohesity usage Stats.xlsx"


$MissingType = [System.Type]::Missing
$WorksheetCount = 8
$excel = New-Object -ComObject excel.application
#$excel.Visible = $True
$Excel.Visible = $False
# Add a workbook
$Workbook = $Excel.Workbooks.Add()
$Workbook.Title = 'Something'
#Add worksheets
$null = $Excel.Worksheets.Add($MissingType, $Excel.Worksheets.Item($Excel.Worksheets.Count), 
$WorksheetCount - $Excel.Worksheets.Count, $Excel.Worksheets.Item(1).Type)
1..8 | ForEach {
    if ($_ -eq 1){
    #$Excel.Worksheets.Item($_).Name = "Hcohesity01 - Usage"
    $worksheet = $workbook.Worksheets.Item($_)
    $worksheet.Name = "chyusnpccp01 - Usage"
    $worksheet.activate|Out-Null
    ### headings for data rows
        $row = 1
        $worksheet.Cells.Item($row,1) = 'Date'
        $worksheet.Cells.Item($row,2) = 'Usage in Tib'
        $row++

        ### authenticate
        apiauth -vip chyusnpccp01 -username $username -domain ent.ad.ntrs.com

        ### calculate startTimeMsecs
        $startTimeMsecs = $(timeAgo $days days)/1000

        ### get cluster info
        $clusterInfo = api get cluster?fetchStats=true
        $clusterId = $clusterInfo.id

        ### collect $days of write throughput stats
        #$stats = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kSystemUsageBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400
        $stats = api get "statistics/timeSeriesStats?entityId=$clusterId&metricName=kMorphedUsageBytes&metricUnitType=0&range=day&rollupFunction=average&rollupIntervalSecs=86400&schemaName=kBridgeClusterStats&startTimeMsecs=$startTimeMsecs"


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
        $worksheet.columns.autofit() | Out-Null
        $worksheet.usedRange.rows(1).Font.Bold = $True
           
    }elseif ($_ -eq 2){
                      $worksheet = $workbook.Worksheets.Item($_)
                      $worksheet.Name = "chyuswpccp01 - Usage"
                      $worksheet.activate|Out-Null
                          ### headings for data rows
                        $row = 1
                        $worksheet.Cells.Item($row,1) = 'Date'
                        $worksheet.Cells.Item($row,2) = 'Usage in Tib'
                        $row++

                        ### authenticate
                        apiauth -vip chyuswpccp01 -username $username -domain ent.ad.ntrs.com

                        ### calculate startTimeMsecs
                        $startTimeMsecs = $(timeAgo $days days)/1000

                        ### get cluster info
                        $clusterInfo = api get cluster?fetchStats=true
                        $clusterId = $clusterInfo.id

                        ### collect $days of write throughput stats
                        #$stats = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kSystemUsageBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400
                        $stats = api get "statistics/timeSeriesStats?entityId=$clusterId&metricName=kMorphedUsageBytes&metricUnitType=0&range=day&rollupFunction=average&rollupIntervalSecs=86400&schemaName=kBridgeClusterStats&startTimeMsecs=$startTimeMsecs"


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
                        $worksheet.columns.autofit() | Out-Null
                        $worksheet.usedRange.rows(1).Font.Bold = $True
                      }  elseif ($_ -eq 3){
                                          $worksheet = $workbook.Worksheets.Item($_)
                                          $worksheet.Name = "chyusnpccp02 - Usage"
                                          $worksheet.activate|Out-Null
                                              ### headings for data rows
                                            $row = 1
                                            $worksheet.Cells.Item($row,1) = 'Date'
                                            $worksheet.Cells.Item($row,2) = 'Usage in Tib'
                                            $row++

                                            ### authenticate
                                            apiauth -vip chyusnpccp02 -username $username -domain ent.ad.ntrs.com

                                            ### calculate startTimeMsecs
                                            $startTimeMsecs = $(timeAgo $days days)/1000

                                            ### get cluster info
                                            $clusterInfo = api get cluster?fetchStats=true
                                            $clusterId = $clusterInfo.id

                                            ### collect $days of write throughput stats
                                            #$stats = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kSystemUsageBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400
                                            $stats = api get "statistics/timeSeriesStats?entityId=$clusterId&metricName=kMorphedUsageBytes&metricUnitType=0&range=day&rollupFunction=average&rollupIntervalSecs=86400&schemaName=kBridgeClusterStats&startTimeMsecs=$startTimeMsecs"


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
                                            $worksheet.columns.autofit() | Out-Null
                                            $worksheet.usedRange.rows(1).Font.Bold = $True
                                          } elseif ($_ -eq 4){
                                      $worksheet = $workbook.Worksheets.Item($_)
                                      $worksheet.Name = "chyuswpccp02 - Usage"
                                      $worksheet.activate|Out-Null
                                          ### headings for data rows
                                        $row = 1
                                        $worksheet.Cells.Item($row,1) = 'Date'
                                        $worksheet.Cells.Item($row,2) = 'Usage in Tib'
                                        $row++

                                        ### authenticate
                                        apiauth -vip chyuswpccp02 -username $username -domain ent.ad.ntrs.com

                                        ### calculate startTimeMsecs
                                        $startTimeMsecs = $(timeAgo $days days)/1000

                                        ### get cluster info
                                        $clusterInfo = api get cluster?fetchStats=true
                                        $clusterId = $clusterInfo.id

                                        ### collect $days of write throughput stats
                                        #$stats = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kSystemUsageBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400
                                        $stats = api get "statistics/timeSeriesStats?entityId=$clusterId&metricName=kMorphedUsageBytes&metricUnitType=0&range=day&rollupFunction=average&rollupIntervalSecs=86400&schemaName=kBridgeClusterStats&startTimeMsecs=$startTimeMsecs"


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
                                        $worksheet.columns.autofit() | Out-Null
                                        $worksheet.usedRange.rows(1).Font.Bold = $True
                                      }  elseif ($_ -eq 5){
                                                          $worksheet = $workbook.Worksheets.Item($_)
                                                          $worksheet.Name = "chyusnpccp03 - Usage"
                                                          $worksheet.activate|Out-Null
                                                              ### headings for data rows
                                                            $row = 1
                                                            $worksheet.Cells.Item($row,1) = 'Date'
                                                            $worksheet.Cells.Item($row,2) = 'Usage in Tib'
                                                            $row++

                                                            ### authenticate
                                                            apiauth -vip chyusnpccp03 -username $username -domain ent.ad.ntrs.com

                                                            ### calculate startTimeMsecs
                                                            $startTimeMsecs = $(timeAgo $days days)/1000

                                                            ### get cluster info
                                                            $clusterInfo = api get cluster?fetchStats=true
                                                            $clusterId = $clusterInfo.id

                                                            ### collect $days of write throughput stats
                                                            #$stats = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kSystemUsageBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400
                                                            $stats = api get "statistics/timeSeriesStats?entityId=$clusterId&metricName=kMorphedUsageBytes&metricUnitType=0&range=day&rollupFunction=average&rollupIntervalSecs=86400&schemaName=kBridgeClusterStats&startTimeMsecs=$startTimeMsecs"


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
                                                            $worksheet.columns.autofit() | Out-Null
                                                            $worksheet.usedRange.rows(1).Font.Bold = $True
                                                          } elseif ($_ -eq 6){
                                                          $worksheet = $workbook.Worksheets.Item($_)
                                                          $worksheet.Name = "chyuswpccp03 - Usage"
                                                          $worksheet.activate|Out-Null
                                                              ### headings for data rows
                                                            $row = 1
                                                            $worksheet.Cells.Item($row,1) = 'Date'
                                                            $worksheet.Cells.Item($row,2) = 'Usage in Tib'
                                                            $row++

                                                            ### authenticate
                                                            apiauth -vip chyuswpccp03 -username $username -domain ent.ad.ntrs.com

                                                            ### calculate startTimeMsecs
                                                            $startTimeMsecs = $(timeAgo $days days)/1000

                                                            ### get cluster info
                                                            $clusterInfo = api get cluster?fetchStats=true
                                                            $clusterId = $clusterInfo.id

                                                            ### collect $days of write throughput stats
                                                            #$stats = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kSystemUsageBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400
                                                            $stats = api get "statistics/timeSeriesStats?entityId=$clusterId&metricName=kMorphedUsageBytes&metricUnitType=0&range=day&rollupFunction=average&rollupIntervalSecs=86400&schemaName=kBridgeClusterStats&startTimeMsecs=$startTimeMsecs"


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
                                                            $worksheet.columns.autofit() | Out-Null
                                                            $worksheet.usedRange.rows(1).Font.Bold = $True
                                                          } elseif ($_ -eq 7)  {
                                                                 $worksheet = $workbook.Worksheets.Item($_)
                                                                 $worksheet.Name = "chyusnpccp05 - Usage"
                                                                 $worksheet.activate|Out-Null
                                                                     ### headings for data rows
                                                                    $row = 1
                                                                    $worksheet.Cells.Item($row,1) = 'Date'
                                                                    $worksheet.Cells.Item($row,2) = 'Usage in Tib'
                                                                    $row++

                                                                    ### authenticate
                                                                    apiauth -vip chyusnpccp05 -username $username -domain ent.ad.ntrs.com

                                                                    ### calculate startTimeMsecs
                                                                    $startTimeMsecs = $(timeAgo $days days)/1000

                                                                    ### get cluster info
                                                                    $clusterInfo = api get cluster?fetchStats=true
                                                                    $clusterId = $clusterInfo.id

                                                                    ### collect $days of write throughput stats
                                                                    #$stats = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kSystemUsageBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400
                                                                    $stats = api get "statistics/timeSeriesStats?entityId=$clusterId&metricName=kMorphedUsageBytes&metricUnitType=0&range=day&rollupFunction=average&rollupIntervalSecs=86400&schemaName=kBridgeClusterStats&startTimeMsecs=$startTimeMsecs"


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
                                                                    $worksheet.columns.autofit() | Out-Null
                                                                    $worksheet.usedRange.rows(1).Font.Bold = $True
                                                                 }
                                                                                          
                                          else  {
                                                 $worksheet = $workbook.Worksheets.Item($_)
                                                 $worksheet.Name = "chyuswpccp05 - Usage"
                                                 $worksheet.activate|Out-Null
                                                     ### headings for data rows
                                                    $row = 1
                                                    $worksheet.Cells.Item($row,1) = 'Date'
                                                    $worksheet.Cells.Item($row,2) = 'Usage in Tib'
                                                    $row++

                                                    ### authenticate
                                                    apiauth -vip chyuswpccp05 -username $username -domain ent.ad.ntrs.com

                                                    ### calculate startTimeMsecs
                                                    $startTimeMsecs = $(timeAgo $days days)/1000

                                                    ### get cluster info
                                                    $clusterInfo = api get cluster?fetchStats=true
                                                    $clusterId = $clusterInfo.id

                                                    ### collect $days of write throughput stats
                                                    #$stats = api get statistics/timeSeriesStats?schemaName=kBridgeClusterStats`&entityId=$clusterId`&metricName=kSystemUsageBytes`&startTimeMsecs=$startTimeMsecs`&rollupFunction=average`&rollupIntervalSecs=86400
                                                    $stats = api get "statistics/timeSeriesStats?entityId=$clusterId&metricName=kMorphedUsageBytes&metricUnitType=0&range=day&rollupFunction=average&rollupIntervalSecs=86400&schemaName=kBridgeClusterStats&startTimeMsecs=$startTimeMsecs"


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
                                                    $worksheet.columns.autofit() | Out-Null
                                                    $worksheet.usedRange.rows(1).Font.Bold = $True
                                                 }   
                                                                              
    

    
}   ### for loop
$excel.DisplayAlerts = $false
$workbook.SaveAs($xlsx,51) | Out-Null


$xlsx = Join-Path -Path (Get-Location).Path -ChildPath "Last Six Months Cohesity usage Stats.xlsx"
$Excel.quit()
## function to close all com objects
function Release-Ref ($ref) {
([System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$ref) -gt 0)
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
}
## close all object references
Release-Ref($WorkSheet)
Release-Ref($WorkBook)
Release-Ref($Excel)

# send email report
#write-host "sending report to $([string]::Join(", ", $sendTo))"
foreach($toaddr in $sendTo){
   Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Last Six Months Cohesity cluster usage Stats." -BodyAsHtml $html  -WarningAction SilentlyContinue -Attachments $xlsx }
#$html | out-file "$($cluster.name)-objectreport.html"


#copy report to NAS share
$today = get-date
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
$html | Copy-Item -Destination $Directory
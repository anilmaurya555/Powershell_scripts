$report_directory = ".\reports"

$merged_reports = @()

# Loop through each XLSX-file in $report_directory
foreach ($report in (Get-ChildItem "$report_directory\*.xlsx")) {

    # Loop through each row of the "current" XLSX-file
    $report_content = foreach ($row in Import-Excel $report) {
        # Create "custom" row
        [PSCustomObject]@{
            "Client name" = $report.Name
            "Date"        = $row."Date"
            "Downtime"    = $row."Downtime"
            "Response"    = $row."Response"
        }
    }

    # Add the "custom" data to the results-array
    $merged_reports += @($report_content)
}

# Create final report
$merged_reports | Export-Excel ".\merged_report.xlsx"
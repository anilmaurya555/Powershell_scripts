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


### create excel spreadsheet
$xlsx = Join-Path -Path (Get-Location).Path -ChildPath "Last Six Months Cohesity usage Stats.xlsx"
$MissingType = [System.Type]::Missing
$WorksheetCount = 4
$excel = New-Object -ComObject excel.application
$excel.Visible = $True
# Add a workbook
$Workbook = $Excel.Workbooks.Add()
$Workbook.Title = 'Something'
#Add worksheets
$null = $Excel.Worksheets.Add($MissingType, $Excel.Worksheets.Item($Excel.Worksheets.Count), 
$WorksheetCount - $Excel.Worksheets.Count, $Excel.Worksheets.Item(1).Type)
1..4 | ForEach {
    $Excel.Worksheets.Item($_).Name = "Name - $($_)"
} 

$excel.DisplayAlerts = $false
$workbook.SaveAs($xlsx,51) | Out-Null
$xlsx = Join-Path -Path (Get-Location).Path -ChildPath "Last Six Months Cohesity usage Stats.xlsx"
$Excel.quit()

# send email report
#write-host "sending report to $([string]::Join(", ", $sendTo))"
foreach($toaddr in $sendTo){
   Send-MailMessage -From $sendFrom -To $toaddr -SmtpServer $smtpServer -Port $smtpPort -Subject "Last Six Months Cohesity usage Stats." -WarningAction SilentlyContinue -Attachments $xlsx }
#$html | out-file "$($cluster.name)-objectreport.html"
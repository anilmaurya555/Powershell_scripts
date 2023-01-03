# Open an Excel workbook first:
$ExcelObj = New-Object -comobject Excel.Application
#$ExcelWorkBook = $ExcelObj.Workbooks.Open("\\cohwpcu01.ent.ad.ntrs.com\cohesity_reports\VM_Data_1228_2022.xlsx")
#$ExcelWorkBook = $ExcelObj.Workbooks.Open("c:\anil\test.xlsx",2,$true)
$ExcelWorkBook = $ExcelObj.Workbooks.Open("\\cohwpcu01.ent.ad.ntrs.com\cohesity_reports\VM_Data_1228_2022.xlsx",2,$true)
$ExcelWorkSheet = $ExcelWorkBook.Sheets.Item("VMAudit")
#$ExcelWorkSheet = $ExcelWorkBook.Sheets.Item("Sheet1")
# Get the number of filled in rows in the XLSX worksheet
$rowcount=$ExcelWorkSheet.UsedRange.Rows.Count
# Loop through all rows in Column 1 starting from Row 2 (these cells contain the domain usernames)
$report = @{}
$outFile = "vm_info.csv"
"VM Name,Vcenter,Disk usage" | Out-File -FilePath $outFile
######

#$data = $ExcelWorksheet.Range("A1:Z100000").Value2
######below code completed in 5 min for excel sheet having 44,000 rows ###
#########################################################################
$data = $ExcelWorksheet.UsedRange.Value2
for( $row = 2 ; $row -lt $data.GetUpperBound(0); $row++) { 
                         #write-host $data[$row, 1] 
                         $vmname = $data[$row, 1]                                     
                         if ( $vmname -notin $report.keys){
                         $report[$vmname] = @{}
                        $report[$vmname]['vcenter'] = $data[$row, 5]
                        $report[$vmname]['datasize'] = $data[$row, 12]
                                                           }
                                                                    
                         }
###########################################################################

<#
for($i=2;$i -le $rowcount;$i++){

$vmname = $ExcelWorkSheet.Columns.Item(1).Rows.Item($i).Text
if ( $vmname -inotin $report.keys){
                        $report[$vmname] = @{}
                        $report[$vmname]['vcenter'] = $ExcelWorkSheet.Columns.Item(5).Rows.Item($i).Text
                        $report[$vmname]['datasize'] = $ExcelWorkSheet.Columns.Item(12).Rows.Item($i).Text

                                    }
}
#>

# Save the XLS file and close Excel
#$ExcelWorkBook.Save()
$ExcelWorkBook.close($true) 
        $report.GetEnumerator()|foreach {

        "$($_.name),$($_.value.vcenter),$($_.value.datasize)" | Out-File -FilePath $outFile -Append
                                        }
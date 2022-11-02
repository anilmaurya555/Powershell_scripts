# process commandline arguments
[CmdletBinding()]
Param ([string]$ServerName)

Function findserver {
  
  
  $ExcelSourceFile = "c:\anil\CMDB_servers_by_application_0715_2021.xlsx"
  $SheetName = "Page 1"
  $CultureOld = [System.Threading.Thread]::CurrentThread.CurrentCulture             #Original culture info
  $CultureUS = [System.Globalization.CultureInfo]'en-US'                            #US culture info

  ###############################################
  # Open Excel File
  ###############################################
  [System.Threading.Thread]::CurrentThread.CurrentCulture = $CultureUS              #Changing the Culture (Regional settings) for this script so we can open the Excel file
  $ExcelSourceObj = New-Object -comobject Excel.Application                         #Excel COM object. This enables us to manipulate excel files
  $ExcelSourceObj.Visible = $True                                                   #Open Excel
  $ExcelWorkbook = $ExcelSourceObj.Workbooks.Open($ExcelSourceFile, 2, $True)       #Opening the Excel file in Read-Only mode
  $ExcelWorkSheet = $ExcelWorkbook.Worksheets.Item($SheetName)                      #Opening Excel Sheet

  ###############################################
  # Find the Row of the server and output the 
  # information
  ###############################################
  $Row = 1
  $Column = 1
  $Found = $False
  "`n{0,-10} {1,-15} {2,-10} {3,-15} {4,-40} {5,-15} {6,-10} {7,-10} {8,-10} {9,-10}" -f ('Server', 'App', 'Status','App Owner', 'Model', 'OS','Equipment', 'State', 'Location','Disk Size')
  "`{0,-10} {1,-15} {2,-10} {3,-15} {4,-40} {5,-15} {6,-10} {7,-10} {8,-10} {9,-10}" -f  ('======', '===============', '=======','===========', '=====', '========','==========', '==========', '========','=======')
  while (($ExcelWorkSheet.Cells.Item($Row, $Column).Value() -ne $Null) -and ($Found -eq $False)) {
                                                                                    #^-- looping though the excel list, updating the row. Stop if Cell is Empty or Value is Found
    If (($ExcelWorkSheet.Cells.Item($Row, $Column).Value()).ToUpper() -eq $ServerName.ToUpper()) {
                                                                                    #^-- Cell value equals $Arg
      #write-host "Server	Application ID	Application Service	Operational status	Recovery Time Objective(RTO)	IT Owner	Business Owner	Model ID	Operating System	IT Equipment Type	Resource State	Location(location)	Patch  Window	DMZ	Rack	Application Technical Owner Email	CPU count	CPU core count	RAM (MB)	PO number	Disk space (GB)"
      #Write-Host $ExcelWorkSheet.Cells.Item($Row, $Column).Value() $ExcelWorkSheet.Cells.Item($Row, $Column+2).Value(),$ExcelWorkSheet.Cells.Item($Row, $Column+3).Value(), $ExcelWorkSheet.Cells.Item($Row, $Column+5).Value(),$ExcelWorkSheet.Cells.Item($Row, $Column+7).Value(),$ExcelWorkSheet.Cells.Item($Row, $Column+8).Value(),$ExcelWorkSheet.Cells.Item($Row, $Column+9).Value(), $ExcelWorkSheet.Cells.Item($Row, $Column+10).Value(),$ExcelWorkSheet.Cells.Item($Row, $Column+11).Value(), $ExcelWorkSheet.Cells.Item($Row, $Column+20).Value() -ForegroundColor green
      #Write-Host $ExcelWorkSheet.Cells..Item($Row, $Column)
      "{0,-10} {1,-15} {2,-10} {3,-15} {4,-40} {5,-15} {6,-10} {7,-10} {8,-10} {9,-10}" -f ($ExcelWorkSheet.Cells.Item($Row, $Column).Value(),$ExcelWorkSheet.Cells.Item($Row, $Column+2).Value(),$ExcelWorkSheet.Cells.Item($Row, $Column+3).Value(), $ExcelWorkSheet.Cells.Item($Row, $Column+5).Value(),$ExcelWorkSheet.Cells.Item($Row, $Column+7).Value(),$ExcelWorkSheet.Cells.Item($Row, $Column+8).Value(),$ExcelWorkSheet.Cells.Item($Row, $Column+9).Value(), $ExcelWorkSheet.Cells.Item($Row, $Column+10).Value(),$ExcelWorkSheet.Cells.Item($Row, $Column+11).Value(), $ExcelWorkSheet.Cells.Item($Row, $Column+20).Value() ) 
      $Found = $True
    }
    $Row += 1                                                                       #Continue to the next row
  }

  ###############################################
  # Close Workbook and Excel
  ###############################################
  $ExcelWorkbook.Close()                                                            #Closing Workbook
  $ExcelSourceObj.Quit()                                                            #Closing Excel
  [System.Threading.Thread]::CurrentThread.CurrentCulture = $CultureOld             #Reverting back to the original Culture (Regional settings)
}
findserver $ServerName
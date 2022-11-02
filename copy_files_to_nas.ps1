# Get the files which should be copied, without folders
$files = Get-ChildItem 'C:\anil\test1' -Recurse | where {!$_.PsIsContainer}
 
# List Files which will be moved
$files
 
# Target Filder where files should be moved to. The script will automatically create a folder for the year and month.
$targetPath = '\\hcohesity05.corpads.local\cohesity_reports'
 
foreach ($file in $files)
{
# Get year and Month of the file
# I used LastWriteTime since this are synced files and the creation day will be the date when it was synced
$year = $file.LastWriteTime.Year.ToString()
$month = $file.LastWriteTime.Month.ToString()
$date  =  $file.LastWriteTime.date.ToString('MM-dd') 
# Out FileName, year and month
$file.Name
$year
$month
$date 
# Set Directory Path
$Directory = $targetPath + "\" + $year + "\" + $month + "\" + $date
# Create directory if it doesn't exsist
if (!(Test-Path $Directory))
{
New-Item $directory -type directory
}
 
# Move File to new location
$file | Copy-Item -Destination $Directory
}

$targetPath = '\\hcohesity05.corpads.local\cohesity_reports'
$year = $file.LastWriteTime.Year.ToString()
$month = $file.LastWriteTime.Month.ToString()
$date  =  $file.LastWriteTime.date.ToString('MM-dd') 
 
# Set Directory Path
$Directory = $targetPath + "\" + $year + "\" + $month + "\" + $date
# Create directory if it doesn't exsist
if (!(Test-Path $Directory))
{
New-Item $directory -type directory
}
 
# copy File to new location
$file | Copy-Item -Destination $Directory

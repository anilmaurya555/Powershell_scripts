# This file contains the list of servers you want to copy files/folders to
$computers = Get-Content "C:\servers.txt"

# This is the file/folder(s) you want to copy to the servers in the $computer variable
$source = "C:\Program Files\Cohesity\cohesity_windows_agent_service.exe"

# The destination location you want the file/folder(s) to be copied to
$destination = "c$\Program Files\Cohesity\"

foreach ($computer in $computers) {
if ((Test-Path -Path \\$computer\$destination)) {
Stop-Service -InputObject $(Get-Service -Computer $computer -Name "Cohesity Agent Service") -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue 
Copy-Item $source -Destination \\$computer\$destination -Verbose -Force
Start-Service -InputObject $(Get-Service -Computer $computer -Name "Cohesity Agent Service") -WarningAction SilentlyContinue -ErrorAction SilentlyContinue 
} 
}

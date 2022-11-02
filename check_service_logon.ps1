$compArray = get-content C:\anil\powershell\Servers.txt

foreach($strComputer in $compArray)

{

Get-WMIObject Win32_Service -ComputerName $strComputer | Where-Object{$_.StartName -eq 'LocalSystem'} | Sort-Object -Property StartName | Format-Table Name, StartName

}
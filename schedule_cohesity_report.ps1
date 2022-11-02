<#-----------------------------------------------------------------------------
  ScheduleIPAddressMailer.ps1
  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me
  This script will create Windows Scheduled Tasks to execute the PowerShell
  script IPAddressMailer.ps1. 
-----------------------------------------------------------------------------#>  
  
$timesToRun = @(
                '09:00am',
                '01:00pm',
                '05:00pm'
               )

$path = 'C:\anil\powershell'
$script = "$path\strikeReport.ps1 sbch-dp01br.selective.com -username maurya1 -domain sigi.us.selective.com -sendTo anil.maurya@selective.com -smtpServer smtphost.selective.com -sendFrom anil.maurya@selective.com"

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
  -Argument "-NoProfile -WindowStyle Hidden -File `"$script`""


foreach ($timeToRun in $timesToRun)
{
   $taskName = "schedule_cohesity_rep_at_$($timeToRun -replace ':', '_')"
   $trigger = New-ScheduledTaskTrigger -Daily -at $timeToRun
   $description = @"
At $timeToRun daily E-Mail the Cohesity Report
"@
  $settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -WakeToRun
  $prin = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" `
                                     -LogonType ServiceAccount `
                                     -RunLevel Highest

  Write-Host "Creating task $taskName" -ForegroundColor Yellow
  Register-ScheduledTask -Action $action `
                         -Trigger $trigger `
                         -TaskName $taskName `
                         -Description $description `
                         -Settings $settings `
                         -Principal $prin `
                         -Force | Out-Null
}

Write-Host 'Here are the list of created tasks.' -ForegroundColor Green
Get-ScheduledTask -TaskPath '\' -TaskName 'schedule_cohesity_rep_at*'

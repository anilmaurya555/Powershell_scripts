<#
SCRIPTNAME: Get-CohesityAlerts.ps1
AUTHOR: Charles Ahern (cahern@cambridgecomputer.com)
COMPANY: Selective Insurance Company
DATE: 2/28/2019
DESCRIPTION: Retrieve alerts from today
MODULES: Cohesity.PowerShell
INPUT FILE FORMAT: None
OUTPUT FILE FORMAT: CSV, HTML
CHANGELOG: 
#>
#Setup Session to Cohesity Cluster

if (!(Get-Module -Name Cohesity.PowerShell)){Import-Module Cohesity.PowerShell}
#$cCluster = "cohesitypoc.sigi.us.selective.com"
$cCluster = "sbch-dp01br.selective.com"
$storedCred = Unprotect-CmsMessage -Path C:\anil\powershell\CCS\creds.txt -To 046C4BF2BF7326A3FE6BB17A6EE5FA2B0BC41351 | ConvertFrom-Csv
$cUser = $storedCred.domain + "\" + $storedCred.username
$cPwd = ConvertTo-SecureString $storedCred.password -AsPlainText -Force
$cCred = New-Object System.Management.Automation.PSCredential($cUser, $cPwd)
Connect-CohesityCluster -Server $cCluster -Credential $cCred
$outCsv =  "c:\anil\powershell\CCS\Reports\CohesityAlerts-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".csv"
$outHTML = "c:\anil\powershell\CCS\Reports\CohesityAlerts-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".html"
$alertInfo = @()
$alerts = Get-CohesityAlert -MaxAlerts 20 -StartTime (Convert-CohesityDateTimeToUsecs -DateTime (Get-Date -Hour 0 -Minute 00 -Second 00))

foreach ($alert in $alerts)
{
    #if([string]::IsNullOrEmpty( -eq $false)){}
    if([string]::IsNullOrEmpty($alert.LatestTimestampUsecs) -eq $false){$atime = Convert-CohesityUsecsToDateTime -Usecs $alert.LatestTimestampUsecs}
    if([string]::IsNullOrEmpty($alert.AlertCategory) -eq $false){$acat = $alert.AlertCategory}
    if([string]::IsNullOrEmpty($alert.AlertState) -eq $false){$astate = $alert.AlertState}
    if([string]::IsNullOrEmpty($alert.Severity) -eq $false){$asev = $alert.Severity}
    if([string]::IsNullOrEmpty($alert.AlertCode) -eq $false){$acode = $alert.AlertCode}
    if([string]::IsNullOrEmpty($alert.AlertDocument.AlertName)-eq $false){$an = $alert.AlertDocument.AlertName}
    if([string]::IsNullOrEmpty($alert.AlertDocument.AlertDescription) -eq $false){$ad = $alert.AlertDocument.AlertDescription}
    if([string]::IsNullOrEmpty($alert.AlertDocument.alertCause) -eq $false){$ac = $alert.AlertDocument.alertCause}
    if([string]::IsNullOrEmpty($alert.AlertDocument.AlertHelpText) -eq $false){$aht = $alert.AlertDocument.AlertHelpText}

    $aInfo = New-Object System.Object
    $aInfo | Add-Member -MemberType NoteProperty -Name "Time" -Value $atime
    $aInfo | Add-Member -MemberType NoteProperty -Name "Category" -Value $acat
    $aInfo | Add-Member -MemberType NoteProperty -Name "State" -Value $astate
    $aInfo | Add-Member -MemberType NoteProperty -Name "Severity" -Value $asev
    $aInfo | Add-Member -MemberType NoteProperty -Name "Code" -Value $acode
    $aInfo | Add-Member -MemberType NoteProperty -Name "Name" -Value $an
    $aInfo | Add-Member -MemberType NoteProperty -Name "Description" -Value $ad
    $aInfo | Add-Member -MemberType NoteProperty -Name "Cause" -Value $ac
    $aInfo | Add-Member -MemberType NoteProperty -Name "HelpText" -Value $aht

    $alertInfo += $aInfo
}

$alertInfo | Export-Csv $outCsv -NoTypeInformation
$alertInfo | ConvertTo-Html | Add-Content $outHTML
$alertInfo | ft -AutoSize
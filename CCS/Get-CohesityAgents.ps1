<#
SCRIPTNAME: Get-CohesityAgents.ps1
AUTHOR: Charles Ahern( cahern@cambridgecomputer.com)
COMPANY: Selective Insurance Company
DATE: 2/27/2019
DESCRIPTION: Get Installed Agent Detail
MODULES: Cohesity.PowerShell
INPUT FILE FORMAT: None
OUTPUT FILE FORMAT: CSV,HTML
CHANGELOG: 
#>

#Setup Session to Cohesity Cluster

if (!(Get-Module -Name Cohesity.PowerShell)){Import-Module Cohesity.PowerShell}
#$cCluster = "cohesitypoc.sigi.us.selective.com"
$cCluster = "cohesitypoc.sigi.us.selective.com"
$storedCred = Unprotect-CmsMessage -Path c:\anil\powershell\CCS\creds.txt -To 046C4BF2BF7326A3FE6BB17A6EE5FA2B0BC41351 | ConvertFrom-Csv
$cUser = $storedCred.domain + "\" + $storedCred.username
$cPwd = ConvertTo-SecureString $storedCred.password -AsPlainText -Force
$cCred = New-Object System.Management.Automation.PSCredential($cUser, $cPwd)
Connect-CohesityCluster -Server $cCluster -Credential $cCred

$outCsv =  "C:\anil\powershell\CCS\CohesityAgents-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".csv"
$outHTML = "C:\anil\powershell\CCS\CohesityAgents-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".html"

$agents = Get-CohesityPhysicalAgent | Select-Object Id,Name,Version,Status,Upgradability,UpgradeStatus,UpgradeStatusMessage,SourceSideDedupEnabled,StatusMessage,@{Name="AuthenticationStatus";expression={$_.RegistrationInfo.AuthenticationStatus}}

$agents | Export-Csv $outCsv -NoTypeInformation
$agents | ConvertTo-Html | Add-Content $outHTML
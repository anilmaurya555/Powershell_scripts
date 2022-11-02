<#
SCRIPTNAME: Get-CohesityView.ps1
AUTHOR: Charles Ahern (cahern@cambridgecomputer.com)
COMPANY: Selective Insurance Company
DATE: 2/26/2019
DESCRIPTION: Capture View Information for Storage Points
MODULES: Cohesity.PowerShell
INPUT FILE FORMAT: None
OUTPUT FILE FORMAT: CSV,HTML
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

$outCsv =  "C:\anil\powershell\CCS\Reports\CohesityView-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".csv"
$outHTML = "C:\anil\powershell\CCS\Reports\CohesityView-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".html"

$cview = Get-CohesityView | Select-Object Name,Description,ProtocolAccess,BasicMountPath,SmbMountPath,NfsMountPath,@{Name='LogicalUsageGB';expression={[math]::round($_.LogicalUsageBytes[0] / 1Gb, 2)}}

$cview  | Export-Csv $outCsv -NoTypeInformation
$cview | ConvertTo-Html | Add-Content $outHTML
$cview | ft -AutoSize
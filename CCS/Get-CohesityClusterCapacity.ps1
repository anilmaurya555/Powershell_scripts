<#
SCRIPTNAME: 
AUTHOR: 
COMPANY: Selective Insurance Company
DATE: 
DESCRIPTION: 
MODULES: 
INPUT FILE FORMAT: 
OUTPUT FILE FORMAT: 
CHANGELOG: 
#>

#Setup Session to Cohesity Cluster

if (!(Get-Module -Name Cohesity.PowerShell)){Import-Module Cohesity.PowerShell}
#$cCluster = "cohesitypoc.sigi.us.selective.com"
$cCluster = "sbch-dp01br.selective.com"
$storedCred = Unprotect-CmsMessage -Path D:\cohesity\CCS\creds.txt -To 046C4BF2BF7326A3FE6BB17A6EE5FA2B0BC41351 | ConvertFrom-Csv
$cUser = $storedCred.domain + "\" + $storedCred.username
$cPwd = ConvertTo-SecureString $storedCred.password -AsPlainText -Force
$cCred = New-Object System.Management.Automation.PSCredential($cUser, $cPwd)
Connect-CohesityCluster -Server $cCluster -Credential $cCred
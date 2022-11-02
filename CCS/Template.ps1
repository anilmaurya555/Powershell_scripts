<#
SCRIPTNAME: Get-JobRecoveryPoints
AUTHOR: Charles Ahern (cahern@cambridgecomputer.com)
COMPANY: Selective Insurance Company
DATE: April 30, 2019
DESCRIPTION: Gets Expiry Information for Protection Jobs
MODULES: Cohesity.PowerShell
INPUT FILE FORMAT: None
OUTPUT FILE FORMAT: CSV, HTML, E-Mail
CHANGELOG: 
#>

#Setup Session to Cohesity Cluster

if (!(Get-Module -Name Cohesity.PowerShell)){Import-Module Cohesity.PowerShell}
$cCluster = "cohesitypoc.sigi.us.selective.com"
$storedCred = Unprotect-CmsMessage -Path C:\Powershell_Files\creds.txt -To 046C4BF2BF7326A3FE6BB17A6EE5FA2B0BC41351 | ConvertFrom-Csv
$cUser = $storedCred.domain + "\" + $storedCred.username
$cPwd = ConvertTo-SecureString $storedCred.password -AsPlainText -Force
$cCred = New-Object System.Management.Automation.PSCredential($cUser, $cPwd)
Connect-CohesityCluster -Server $cCluster -Credential $cCred


$outCsv =  ".\CohesityProtectionJobs-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".csv"
$outHTML = ".\CohesityProtectionJobs-" + (Get-Date).ToLocalTime().ToString().Replace("/", "_").Replace(":", "_") + ".html"
$cPjInfo = @()
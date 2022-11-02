
### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][string]$domain = 'local',
   [Parameter()][array]$emailAddresses = '' # optional names of servers to protect (comma separated)
   
   
)
#Connect-CohesityCluster -Credential (Get-Credential $Credentials) -Server sbch-dp03br
#$emailAddresses = @('itstorageandbackupservices@selective.com', 'itopsmon@selective.com')
### source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

### authenticate
apiauth -vip $vip -username $username -domain $domain

Get-CohesityProtectionJob -Names TRANS | ForEach-Object {

    if($_.AlertingConfig){

        foreach($emailAddress in $emailAddresses){

            $_.AlertingConfig.EmailAddresses += $emailAddress
                   }

    }else{

        $_.AlertingConfig = [Cohesity.Model.AlertingConfig]::new($emailAddresses)

    }

    $_.AlertingConfig.EmailAddresses = $_.AlertingConfig.EmailAddresses | select -Unique
    
    
    $_ | Set-CohesityProtectionJob

}


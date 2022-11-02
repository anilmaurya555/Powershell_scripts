Connect-CohesityCluster -Credential (Get-Credential $Credentials) -Server sbch-dp03br
$emailAddresses = @('itstorageandbackupservices@selective.com', 'itopsmon@selective.com')

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


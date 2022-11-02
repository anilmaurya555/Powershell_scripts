### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip,
    [Parameter(Mandatory = $True)][string]$username,
    [Parameter()][string]$domain = 'local',
    [Parameter()][array]$jobnames = '',
   [Parameter()][array]$emailAddresses = '' # optional names of servers to protect (comma separated)
   
   
)
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)
### authenticate
apiauth -vip $vip -username $username -domain $domain
$jobs = @() 
                          #$alljobs = api get protectionJobs?isDeleted=false
                          $alljobs = api get protectionJobs | Where-Object {$_.isdeleted -ne $True -and $_.isactive -ne $false }
                 
  foreach ( $job in $alljobs ) {
                            if (!$jobnames){
                             $jobid= $job.id
                             if($job.AlertingConfig){

                                foreach($emailAddress in $emailAddresses){
                                       $job.AlertingConfig.EmailAddresses += $emailAddress
                                            }
                                                }else{
                                                     $job.AlertingConfig = [Cohesity.Model.AlertingConfig]::new($emailAddresses)
                                                    }
                                        $job.AlertingConfig.EmailAddresses = $job.AlertingConfig.EmailAddresses | select -Unique
                                                      $null = api put protectionJobs/$jobid $job
                                                     "$($job.name) updated"
                                            } else {
                                               foreach ($jobname in $jobnames){
                                                                if ($job.name -eq $jobname){
                                                                $jobid= $job.id
                                                                if($job.AlertingConfig){

                                                             foreach($emailAddress in $emailAddresses){
                                                            $job.AlertingConfig.EmailAddresses += $emailAddress
                                                              }
                                                                }else{
                                                            $job.AlertingConfig = [Cohesity.Model.AlertingConfig]::new($emailAddresses)
                                                               }
                                                            $job.AlertingConfig.EmailAddresses = $job.AlertingConfig.EmailAddresses | select -Unique
                                                              $null = api put protectionJobs/$jobid $job
                                                            "$($job.name) updated"
                                                                         }
                                                                         }
                                                  }


                            } 

                             



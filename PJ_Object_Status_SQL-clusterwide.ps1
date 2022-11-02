
#ensure your environment meets the prerequisites listed here, and you have downloaded and implemented the Cohesity PowerShell Module: https://cohesity.github.io/cohesity-powershell-module/#/pre-requisites 
    #Install-Module -Name Cohesity.PowerShell 
    #Install-Module -Name Cohesity.PowerShell.Core 
    #Install-Module -Name Core 

#replace username and password values with Cohesity UI (iris_cli) credentials
#replace server value with the IP or FQDN of the Cohesity Cluster (example: 172.20.1.1 or "cohesity.cluster.com")
$username = "admin"
$password = "a21MaW3s0m3IPe" | ConvertTo-SecureString -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ($Username,$Password)
$server = "sbch-dp01br.selective.com" 

#replace Server IP with Cohesity Cluster VIP
Connect-CohesityCluster -Credential (Get-Credential $Credentials) -Server $server

#$ProtectionJobs = Get-CohesityProtectionJob -Environments kVMware | Select-Object -ExpandProperty Id 

#SQL Options
    $ProtectionJobs = Get-CohesityProtectionJob -Environments kSQL | Select-Object -ExpandProperty Id 

#iterates each output JobId through the following function
$results = foreach ($JobId in $ProtectionJobs)
{
    #pulls backup run(s) per each VMware JobId
    #change -NumRuns value to depict how many Protection Job Runs you want to output per Job
    #converts output into Json oriented referencable variables
    #$backupRunObj = Get-CohesityProtectionJobRun -JobId $JobId -ExcludeNonRestoreableRuns -NumRuns 1 | ConvertFrom-Json

    #SQL OptionsCohe$1ty
    $backupRunObj = Get-CohesityProtectionJobRun -JobId $JobId -RunTypes kRegular -ExcludeNonRestoreableRuns -NumRuns 1 | select-string backuprun 
        #NumRuns, StartTime, StartedTime do not output accurate data

        #output for Protection Job Run and Objects
        $ProtectionJobStats = [PSCustomObject]@{
            clusterId = $backupRunObj.jobUid.clusterId

            jobName = $backupRunObj.jobName
            ProtectionJobId = $backupRunObj.JobId
            runType = $backupRunObj."backupRun".runType
            ProtectionJobStatus = $backupRunObj."backupRun".status
            ProtectionJobError = $backupRunObj."backupRun".error
            ProtectionJobTimeTaken = $backupRunObj."backupRun".sourceBackupStatus.source.stats.timeTakenUsecs
            ProtectionJobtotalLogicalBackupSizeBytes = $backupRunObj."backupRun".stats.totalLogicalBackupSizeBytes
            ProtectionJobtotalPhysicalBackupSizeBytes = $backupRunObj."backupRun".stats.totalPhysicalBackupSizeBytes
            
            ObjectName = $backupRunObj."backupRun".sourceBackupStatus.source.name
            ObjectStatus = $backupRunObj."backupRun".sourceBackupStatus.status
            FullBackup = $bbackupRunObj."backupRun".sourceBackupStatus.isFullBackup
             
            RunStats = $backupRunObj."backupRun".stats
            SQLsource = $backupRunObj."backupRun".sourceBackupStatus.source
            SourceTimeTaken = $backupRunObj."backupRun".sourceBackupStatus.source.stats.timeTakenUsecs
            SourcetotalLogicalBackupSizeBytes = $backupRunObj."backupRun".sourceBackupStatus.source.stats.totalLogicalBackupSizeBytes
            SourcetotalPhysicalBackupSizeBytes = $backupRunObj."backupRun".sourceBackupStatus.source.stats.totalPhysicalBackupSizeBytes


            remote_replication_error = $backupRunObj."copyRun".error 
            # $backupRunObj."copyRun".error | where-object {$_.$backupRunObj."copyrun".target -Contains "kRemote"}
            # $backupRunObj."copyRun".error | where-object {$_.$backupRunObj."copyrun".target -like '*kRemote*'}  
            }
        Write-Output "Protection Job Info" $ProtectionJobStats | Format-List    
        }

#replace with preferred output directory and filename
$results
#$results | Out-file c:\anil\powershell\PJ_Object_VM-clusterwide-RESULTS.txt 

# This file contains the list of servers you want to upgrade the Cohesity Agent on (1 FQDN/IP per line)
$computers = Get-Content "C:\servers.txt"

# This is the name of the Cohesity Agent Installer
$agentFile = "Cohesity_Agent_6.2.1a_Win_x64_Installer.exe"

# This is the Cohesity Agent installer you need to copy to the servers in the $computer variable (update SHARENAME to the name of the network share)
$source = "\\SHARENAME\$agentFile"

# The destination directory you want the Cohesity Agent installer to be copied to
$destination = "c$\Windows\Temp"
$localDestination = "C:\Windows\Temp"


# The below code references the above variables and iterates through each Windows Server
foreach ($computer in $computers) {
        if ((Test-Path -Path \\$computer\$destination)) {

                # The below code copies the Cohesity Agent installer to the $destination directory on each Windows Server
                Copy-Item $source -Destination \\$computer\$destination -Verbose -Force

                $remoteFilePath = Join-Path -Path $localDestination -ChildPath $agentFile

                # The below code installs the agent on each Windows Server
                Invoke-Command -Computername $computer -ScriptBlock {
                        msiexec $remoteFilePath /verysilent /supressmsgboxes /norestart
                }                                       
        }
}       

Out-File -FilePath $localDestination\agent_installer.txt  
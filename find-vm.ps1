Function Find-VM 
{
    <#
    .SYNOPSIS
        Search all vCenter* servers for a particular VM
    .DESCRIPTION
        If you need to locate a VM and you're not sure which vCenter, Datacenter, or Cluster it
        might be on, use this script to locate it.

        Since there's no easy way to determine your vCenter server name, you will need to edit the
        script and put it in the $vCenters variable below.  Multiple vCenters are support (in fact,
        the primary point of the server is to search multiple vCenters).

    .PARAMETER Name
        Name of the VM you're looking for

    .INPUTS
        Server Name
        [Microsoft.ActiveDirectory.Management.ADComputer]

    .OUTPUTS
        PSCustomObject
            Name           Name of VM
            GuestOS        Operating System of the VM
            VCenter        Which VCenter the VM was located on
            DataCenter     DataCenter it's under
            Cluster        Cluster (if any) it's in
            Host           Which ESX server it's running on

    .EXAMPLE
        Find-VM -Name lostserver1,lostserver2,lostserver3

        Will locate the 3 "lostserver's" and return information about where they're located in your
        vCenter setup.

    .EXAMPLE
        Get-ADComputer -Filter {Name -like "lostserver*"} | Find-VM

        Will locate all of the "lostserver's" in Active Directory in all then locate them in your
        vCenter.

    .EXAMPLE
        Get-Content c:\path\serverlist.txt | Find-VM

        Will locate every server that's listed in serverlist.txt

    .NOTES
        Author:             Martin Pugh
        Twitter:            @thesurlyadm1n
        Spiceworks:         Martin9700
        Blog:               www.thesurlyadmin.com
      
        Changelog:
            1.0             Initial Release
    .LINK
        http://community.spiceworks.com/scripts/show/3048-find-vm-locate-a-vm-in-multiple-vcenter-installations
    #>
    #requires -Version 3.0
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("VM","ComputerName")]
        [string[]]$Name
    )

    BEGIN {
        #Enter your vCenter server names here:
        $vCenters = @(
            "vcenter1"
            "vcenter2"
        )


        Write-Verbose "$(Get-Date): Find-VM started"
        Add-PSSnapin Vmware.VimAutomation.Core
        $VMs = New-Object -TypeName System.Collections.ArrayList
    }

    PROCESS {
        ForEach ($VM in $Name)
        {
            $VMs.Add($VM) | Out-Null
        }
    }

    END {
        ForEach ($vCenter in $vCenters)
        {
            Write-Verbose "$(Get-Date): Looking for $($VMs -join ', ')"
            Write-Verbose "$(Get-Date): Checking $vCenter..."
            $Connect = Connect-VIServer $vCenter 3> $null
            $VMObjs = Get-VM $VMs -ErrorAction SilentlyContinue
            ForEach ($VMObj in $VMObjs)
            {
                [PSCustomObject]@{
                    Name = $VMObj.Name
                    GuestOS = $VMObj.ExtensionData.Guest.GuestFullName
                    VCenter = $vCenter
                    DataCenter = $VMObj | Get-DataCenter | Select -ExpandProperty Name
                    Cluster = $VMObj | Get-VMHost | Get-Cluster | Select -ExpandProperty Name
                    Host = $VMObj | Get-VMHost | Select -ExpandProperty Name
                }
            }
            Disconnect-VIServer $vCenter -Confirm:$false
        }
        Write-Verbose "$(Get-Date): Find-VM finished"
    }
}
# process commandline arguments
[CmdletBinding()]
param (
    [Parameter()][string]$server = ''  # optional name of one server protect
    )
        
	
	if (TestPing $server -eq $true) 
		{
			$nicinfo = gwmi win32_networkadapterconfiguration -computer $server -ea stop
			$hostip = 	$nicinfo | where-Object {$_.dnsHostName -match "\w"}
			
			$sysObj = $server | get-computerInfo 
		
			"`n"
			"System Information: {0}" -f $sysObj.computer 
			"---------------------------------------------------------------------"
			"Hardware:{0} / {1}" -f $sysObj.Mfg, $sysObj.Model
			"---------------------------------------------------------------------"
			"{0} SP:{1}" -f $sysObj.OS_name, $sysObj.os_sp
			"System Drive:{0}" -f $sysObj.system_dir
			"---------------------------------------------------------------------"
			"RAM (MB):{0:N0}             Pagefile (MB):{1:N0} " -f $sysObj.ram_size, $sysObj.page_size 
			"---------------------------------------------------------------------"
			$server | get-diskspace | Format-Table -Property Drive,Size-MB,Free-MB,File_System,Description,Provider -AutoSize
		
			Write-Host "`n"
			Write-Host "-------------------"
			Write-Host "Network Information" -ForegroundColor "Yellow"
			Write-Host "-------------------"
			
			$hostip |
			where {$_.DNSHostName.length -gt 1} | 
			select dnsHostName, IPAddress, dnsServerSearchOrder, WINSPrimaryServer, WINSSecondaryServer, Description | Format-List
		
			Write-Host "`n"
		} 
	else 
		{ 
			Write-Host "Invalid Name or Server Unavailable" 
		}

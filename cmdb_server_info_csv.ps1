 # process commandline arguments
[CmdletBinding()]
Param ([array]$ServerNames)

"`n{0,-10} {1,-15} {2,-10} {3,-15} {4,-40} {5,-15} {6,-10} {7,-10} {8,-10} {9,-10}  {10,-15}" -f ('Server', 'App', 'Status','App Owner', 'Model', 'OS','Equipment', 'State', 'Location','Disk Size','Email Add')
  "`{0,-10} {1,-15} {2,-10} {3,-15} {4,-40} {5,-15} {6,-10} {7,-10} {8,-10} {9,-10}  {10,-15}" -f  ('======', '===============', '=======','===========', '=====', '========','==========', '==========', '========','=======','=======')
$OUTPUT = @()
foreach ( $server in $serverNames){
$data = Import-Csv c:\anil\cmdb_inventory_0516_2022.csv |?{$_.u_server -match $Server}|select -First 1
if ($data -eq $null ){
                     write-host "======= $server ======= Not In cmdb ==" -ForegroundColor Red
                     break 
                     } else {
$len1 = [math]::Min(15, $data."u_application_service".Length)
$len2 = [math]::Min(40, $data."u_server.model_id".Length)
$len3 = [math]::Min(15, $data."u_server.os".Length)
$OUTPUT += "{0,-10} {1,-15} {2,-10} {3,-15} {4,-40} {5,-15} {6,-10} {7,-10} {8,-10} {9,-10}  {10,-15}" -f $($data."u_server"),$($data."u_application_service").Substring(0, $len1),$($data."u_application_service.operational_status"), $($data."u_application_service.supported_by"),$($data."u_server.model_id").Substring(0, $len2),$($data."u_server.os").Substring(0, $len3),$($data."u_server.u_it_equipment_type"), $($data."u_server.u_hpam_resource_state"),$($data."u_server.location"), $($data."u_server.disk_space"),$($data."u_server.u_equipment_technical_owner_email")
                               }
                                  } 
                                
$OUTPUT
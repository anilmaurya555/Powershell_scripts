#########################################manuplation of MMINFO ###############
######mminfo -avot -q "savetime >= '24 February 2022', savetime <= '24 March 2022'" -r client,totalsize,group,policy,workflow,level,sscreate,ssretent,clretent,device,family,nsavetime,action,sumsize,name,location
################################################################################3
$out=Get-Content C:\anil\networker\mminfo_0324_2022.txt
$ht = @{}
$arr = @()
$today = Get-Date
$outFile = $(Join-Path -Path $PSScriptRoot -ChildPath "Networker_fetb_$(get-date -UFormat '%Y-%m-%d-%H-%M-%S').csv")
"Server Nam:Overall Size in MB:DB2 Size in MB:RMAN Size in MB:File Size in MB:Groups Name:Backup Type" | Out-File -FilePath $outFile
foreach ( $line in $out){
              $arr=$line.Split(" ")
              if ($arr[0] -notin  $ht.keys){
                                 $ht[$arr[0]] = @{}
                                 } 
                          } #### looping thru file
$ht.GetEnumerator()| ForEach-Object {
"{0,-25}" -f $_.name
}

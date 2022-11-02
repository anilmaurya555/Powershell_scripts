$ServerName = Get-Content "c:\anil\powershell\servers.txt"
foreach ( $server in $ServerName) {
$user = "s-cohesity-sql";
If ((New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq $FALSE){
      Write-Host "$user exists in the group $group on $server"
 } 
      Else {
        Write-Host "$user not exists in the group $group on $server"
}       
       }
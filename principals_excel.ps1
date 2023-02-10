### process commandline arguments
[CmdletBinding()]
param (
    #[Parameter(Mandatory = $True)][string]$vip, #the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username, #username (local or AD)
    [Parameter()][string]$domain = 'ent.ad.ntrs.com' #local or AD domain
)

### source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)


"ClusterNmae,AccountType,Doamin,Name,Permission"|Out-File -FilePath ./accountpermissions.csv

$vips = ('cohwpcu01','cohsdcu01')
$permisions = @{}
foreach ($vip in $vips){

if ($vip -notin $permisions.keys){
$permisions[$vip] = @{}
$permisions[$vip]['Users']=@{}
$permisions[$vip]['Groups']=@{}
}

### authenticate
apiauth -vip $vip -username $username -domain $domain


$cluster = api get cluster
$outFile = "principals-$($cluster.name).txt"
$null = Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue

$roles = api get roles
$users = api get users?_includeTenantInfo=true
$groups = api get groups?_includeTenantInfo=true
$parents = @{}


foreach($user in $users | Sort-Object -Property username){
            if ($user.domain -notin $permisions[$vip]['Users'].keys){
            $permisions[$vip]['Users'][$user.domain] = @{} }

         if($user.PSObject.Properties['roles']){
        $proles = $roles | Where-Object name -in $user.roles
        
        if($user.username){
           $pname = $user.username}else{ $pname = $user.name}
           $ptype = "User"
          # "`n{0}: {1}/{2}" -f $ptype.ToUpper(), $user.domain, $pname
           #"Roles: {0}" -f $proles.label -join ', '
        $permisions[$vip]['Users'][$user.domain][$pname] = $proles.label -join ', '

        if($user.restricted -eq $True){
            "Access List:"
            $psources = api get principals/protectionSources?sids=$($user.sid)
            foreach($source in $psources[0].protectionSources){
                $sourceName = $source.name
                $sourceType = $source.environment.substring(1)
                $parentId = $source.parentId
                if($parentId){
                    if($parentId -in $parents.Keys){
                        $parentName = $parents[$parentId]
                    }else{
                        $parent = api get protectionSources/objects/$parentId
                        $parents[$parentId] = $parent.name
                        $parentName = $parent.name
                    }
                    "       {0}/{1} ({2})" -f $parentName, $sourceName, $sourceType
                         $permisions[$vip]['Users'][$user.domain][$pname]['Access List'] = "$parentName/$sourceName, $sourceType"
                }else{
                    "       {0} ({1})" -f $sourceName, $sourceType
                    $permisions[$vip]['Users'][$user.domain][$pname]['Access List'] = "$sourceName, $sourceType"
                }

                
            }
            foreach($view in $psources[0].views){
                "       {0} ({1})" -f $view.name, "View"
                $permisions[$vip]['Users'][$user.domain][$pname]['Access List'] = "$view.name"
            }
        }  ##restricted end 
    }  ##look for roles
}

foreach($group in $groups | Sort-Object -Property name){
    if ($group.domain -notin $permisions[$vip]['Groups'].keys){
    $permisions[$vip]['Groups'][$group.domain] = @{}}
     if($group.PSObject.Properties['roles']){
        $proles = $roles | Where-Object name -in $group.roles
        

         if($group.username){
           $pname = $group.username}else{ $pname = $group.name}
           $ptype = "Group"
           #"`n{0}: {1}/{2}" -f $ptype.ToUpper(), $group.domain, $pname
           #"Roles: {0}" -f $proles.label -join ', '
        $permisions[$vip]['Groups'][$group.domain][$pname] = $proles.label -join ', '

        if($group.restricted -eq $True){
            "Access List:"
            $psources = api get principals/protectionSources?sids=$($group.sid)
            foreach($source in $psources[0].protectionSources){
                $sourceName = $source.name
                $sourceType = $source.environment.substring(1)
                $parentId = $source.parentId
                if($parentId){
                    if($parentId -in $parents.Keys){
                        $parentName = $parents[$parentId]
                    }else{
                        $parent = api get protectionSources/objects/$parentId
                        $parents[$parentId] = $parent.name
                        $parentName = $parent.name
                    }
                    "       {0}/{1} ({2})" -f $parentName, $sourceName, $sourceType
                         $permisions[$vip]['Groups'][$group.domain][$pname]['Access List'] = "$parentName/$sourceName, $sourceType"
                }else{
                    "       {0} ({1})" -f $sourceName, $sourceType
                    $permisions[$vip]['Groups'][$group.domain][$pname]['Access List'] = "$sourceName, $sourceType"
                }

                
            }
            foreach($view in $psources[0].views){
                "       {0} ({1})" -f $view.name, "View"
                $permisions[$vip]['Groups'][$group.domain][$pname]['Access List'] = "$view.name"
            }
        }  ##restricted end 
    }  ##look for roles
}

}
$permisions.GetEnumerator()|%{
$vip = $_.name
foreach ($cluster in $_.value.GetEnumerator()){  ####type
  $type = $cluster.name

  foreach ($dom in $cluster.value.GetEnumerator()){ ###dom
       $domain = $dom.name
            foreach ($prin in $dom.value.GetEnumerator()){

               # "{0} {1} {2} {3} " -f $vip,$type,$prin.name,$prin.value                   
 
"$vip,$type,$domain,$($prin.name),$($prin.value) "|Out-File -FilePath ./accountpermissions.csv -Append
                                                         }

                                               }    ##dom

                                             }   ###type

                            }
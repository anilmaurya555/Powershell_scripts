### process commandline arguments
[CmdletBinding()]
param (
    #[Parameter(Mandatory = $True)][string]$vip, #the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username, #username (local or AD)
    [Parameter()][string]$domain = 'ent.ad.ntrs.com' #local or AD domain
)

### source the cohesity-api helper code
. $(Join-Path -Path $PSScriptRoot -ChildPath cohesity-api.ps1)

### create excel spreadsheet
$xlsx = Join-Path -Path (Get-Location).Path -ChildPath "Cohesity_complete_Permission_list-$(get-date -UFormat '%Y-%m-%d-%H-%M-%S').xlsx"
write-host "Saving Report to $xlsx..."
$excel = New-Object -ComObject excel.application
$workbook = $excel.Workbooks.Add()
$worksheets=$workbook.worksheets
$sheet=$worksheets.item(1)
$sheet.activate | Out-Null

### Column Headings
$sheet.Cells.Item(1,1) = 'Cohesity Cluster'
$sheet.Cells.Item(1,2) = 'Account Type'
$sheet.Cells.Item(1,3) = 'Domain Name'
$sheet.Cells.Item(1,4) = 'Name'
$sheet.Cells.Item(1,5) = 'Permission'
$sheet.usedRange.rows(1).font.colorIndex = 10
$sheet.usedRange.rows(1).font.bold = $True
$rownum = 2

#"ClusterNmae,AccountType,Doamin,Name,Permission"|Out-File -FilePath ./accountpermissions.csv

#$vips = ('chyukrccp01')
$vips = ('chyididcp01','chymaidcp01','chysgpccp01','chysgrccp01','chyukpccp01','chyukrccp01','chyusnpccp01','chyuswpccp01','chyusnpccp02','chyuswpccp02','chyusnpccp03','chyuswpccp03','chyusnpccp04','chyuswpccp04','chyusnpccp05','chyuswpccp05')
$permisions = @{}
foreach ($vip in $vips){

if ($vip -notin $permisions.keys){
$permisions[$vip] = @{}
$permisions[$vip]['Users']=@{}
$permisions[$vip]['Groups']=@{}
}

### authenticate
apiauth -vip $vip -username $username -domain $domain
"============= $vip ================"

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
           #"`n{0}: {1}/{2}" -f $ptype.ToUpper(), $user.domain, $pname
          #"Roles: {0}" -f $proles.label -join ', '
        $permisions[$vip]['Users'][$user.domain][$pname] = $proles.label -join ', '

        <#if($user.restricted -eq $True){
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
                         #$permisions[$vip]['Users'][$user.domain][$pname]['Access List'] = $parentName/$sourceName, $sourceType
                }else{
                    "       {0} ({1})" -f $sourceName, $sourceType
                    #$permisions[$vip]['Users'][$user.domain][$pname]['Access List'] = $sourceName, $sourceType
                }

                
            }
            foreach($view in $psources[0].views){
                "       {0} ({1})" -f $view.name, "View"
                #$permisions[$vip]['Users'][$user.domain][$pname]['Access List'] = $view.name
            }
        }  ##restricted end #>
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

        <#if($group.restricted -eq $True){
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
                         #$permisions[$vip]['Groups'][$group.domain][$pname]['Access List'] = $parentName/$sourceName, $sourceType
                }else{
                    "       {0} ({1})" -f $sourceName, $sourceType
                    #$permisions[$vip]['Groups'][$group.domain][$pname]['Access List'] = $sourceName,$sourceType
                }

                
            }
            foreach($view in $psources[0].views){
                "       {0} ({1})" -f $view.name, "View"
                #$permisions[$vip]['Groups'][$group.domain][$pname]['Access List'] = $view.name
            }
        }  ##restricted end #>
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
 
#"$vip,$type,$domain,$($prin.name),$($prin.value) "|Out-File -FilePath ./accountpermissions.csv -Append

####### populate Excel sheet
if($job.isActive -ne $false ){  #3
        $sheet.Cells.Item($rownum,1) = $vip
        $sheet.Cells.Item($rownum,2) = $type
        $sheet.Cells.Item($rownum,3) = $domain
        $sheet.Cells.Item($rownum,4) = $($prin.name)
        $sheet.Cells.Item($rownum,5) = $($prin.value)
        $rownum += 1
    }   #3
    ################end of excel sheet population
                                                         }

                                               }    ##dom

                                             }   ###type

                            }
### final formatting and save
$sheet.columns.autofit() | Out-Null
$sheet.columns("Q").columnWidth = 100
$sheet.columns("Q").wraptext = $True
$sheet.usedRange.rows(1).Font.Bold = $True
$excel.Visible = $true
$workbook.SaveAs($xlsx,51) | Out-Null
$workbook.close($false)
$excel.Quit()

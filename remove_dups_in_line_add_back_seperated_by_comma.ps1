$contents = get-content "c:\anil\scripts\group_dups.txt"
$NewFile = Join-Path -Path $PSScriptRoot -ChildPath "new_groups.txt"

foreach($content in $contents){
$group = @() 
$i = 1                       
    $temp = ($content -replace '\s+', ' ').split()
    
    for (;$i -lt 15 ; $i++  ){
            if ($temp[$i] -notin $group){
                               $group += $temp[$i]
                                            }
    
                            }
                            $newgroup = $group -join ","
                            $newgroup|Tee-Object -FilePath $newfile -Append 
                            
                            }
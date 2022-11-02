$text = gc C:\anil\scripts\dups.txt
 $outfileName = "device_pool_mapping.txt"
 $nl = [System.Environment]::NewLine
$groups = ($text | out-string) -split ("$nl$nl") 
$columns = $groups | % {$_.trim().split("`n")[0]}
$rows = $groups | % {$_.trim().Split("`n").count - 2} | sort -desc | select -f 1

$result = 0..$rows | % {
    $row = $_
    $obj = New-Object psobject
    0..$($columns.Count-1) | % {
        $column = $columns[$_].split(":")[1].trim(";")
        $store = $groups[$_].trim().split("`n")
        $item = $store[$row+1]
        $obj | Add-Member -MemberType NoteProperty -Name $column.trim() -Value $(if ($item) {$item.trim()})
    }
    $obj
}
$result 
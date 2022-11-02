$text = gc C:\anil\scripts\input.txt
$groups = ($text | out-string) -split 'THE END' | ? {$_ -notmatch '^(?:\s+)?$'}
#$groups = ($text | out-string) | ? {$_ -notmatch '^(?:\s+)?$'}
$columns = $groups | % {$_.trim().split("`n")[0]}
$rows = $groups | % {$_.trim().Split("`n").count - 2} | sort -desc | select -f 1
$rows
$result = 0..$rows | % {
    $row = $_
    $obj = New-Object psobject
    0..$($columns.Count-1) | % {
        $column = $columns[$_]
        $store = $groups[$_].trim().split("`n")
        $item = $store[$row+1]
        $obj | Add-Member -MemberType NoteProperty -Name $column.trim() -Value $(if ($item) {$item.trim()})
    }
    $obj
}
$result 

#$result | epcsv C:\temp\input.csv -NoTypeInformation
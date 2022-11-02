$dir = "C:\anil"
$count = @{}
$size = @{}

gci $dir |%{
[int]$count[$_.extension] += 1
[int64]$size[$_.extension] += $_.length
}

#$count.Keys
$size.keys
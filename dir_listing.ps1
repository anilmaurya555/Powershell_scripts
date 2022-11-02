$dir = "C:\anil"
$count = @{}
$size = @{}

gci $dir -recurse -exclude cohesity |%{
$_
[int]$count[$_.extension] += 1
[int64]$size[$_.extension] += $_.length
}
$results = @()
$count.keys | sort |% {
$result = ""|select extension,count,size,hostname # this sets table then later they get value assigned below
$result.extension = $_
$result.count = $count[$_]
$result.size = $size[$_]
$result.hostname = $(get-content env:computername)
$results += $result
}
$results | ft -auto
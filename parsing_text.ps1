$pattern = '-'*81  
$content = Get-Content c:\anil\Scripts\input.txt | Out-String
$content.Split($pattern,[System.StringSplitOptions]::RemoveEmptyEntries) | Where-Object {$_ -match '\S'} | ForEach-Object {

$item = $_ -split "\s+`n" | Where-Object {$_}

    New-Object PSobject -Property @{
        Name=$item[0].Split(':')[-1].Trim()
        Id = $item[1].Split(':')[-1].Trim()
        ResolutionPath=$item[2].Split(':')[-1].Trim()
        Endpoints=$item[4..($item.Count)]
    } | Select-Object Name,Id,ResolutionPath,Endpoints
}
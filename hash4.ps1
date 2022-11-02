$DebugPreference = 'Continue'
$lines = Get-Content "$PSScriptRoot\dups.txt"
$ddlines = Get-Content  "$PSScriptRoot\pool_dd.txt"
$outFile = 'output.txt'
$clients = @{}
$dds = @{}
### get report
Write-Debug "what is `$clients before loops"
$clients
Write-Debug "==>`$clients"
foreach ( $line in $ddlines) {
    #split each line by single space - does not return anything in the split that is null/empty (multiple spaces)
    $splitDDline = $line.split('	',[System.StringSplitOptions]::RemoveEmptyEntries)
    $pool = $splitDDline[0]
    $dd = $splitDDline[1]
    $vars = @"
  `n
    `$line = $line
    `$pool = $pool
    `$dd = $dd
"@
    Write-Debug $vars
    if ($pool -notin $dds.keys) {
        $dds[$pool] = $dd
    }
}



foreach ($line in $lines) {
    #split each line by single space - does not return anything in the split that is null/empty (multiple spaces)
    $splitDupsLine = $line.split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
    #set variables based on result of $splitLines
    $pool = $splitDupsLine[0]
    $client = $splitDupsLine[1]
    $db = $splitDupsLine[2]
    $dd = $dds[$pool]
    $varCheck = @"
    `n
    `$pool is $pool
    `$client is $client
    `$db is $db
    `$dd is $dd
    `$dds[`$pool] is $dds[$pool]
"@
    Write-Debug $varCheck
    if ($client -notin $clients.Keys) {
        Write-Debug "$client is not in `$clients.Keys"
        $clients[$client] = @{
            'pool' = @()
        }
        $clients[$client]['db'] = @{
            'db' = @()
        }
        $clients[$client]['dd'] = @{
            'dd' = @()
        }
        $clients[$client].pool = $pool
        $clients[$client].db = $db
        $clients[$client].dd = $dd
    }
    else {
        Write-Debug "$client found in `$clients.Keys"
        $poolCheck = $pool | Where-Object -FilterScript { $_ -notin $clients[$client]['pool'] }
        Write-Debug "`$poolCheck is $poolCheck"
        if ($poolcheck.Count -gt 0) {
            $clients[$client]['pool'] += $poolCheck
        }
        else {
            "Nothing to add to pool"
        }
        $dbCheck = $db | Where-Object -FilterScript { $_ -notin $clients[$client]['db'] }
        if ($dbcheck.Count -gt 0) {
            $clients[$client]['db'] += $dbCheck
        }
        else {
            "Nothing to add to db"
        }
        $ddCheck = $pool | Where-Object -FilterScript { $_ -notin $clients[$client]['dd'] }
        if ($ddcheck.Count -gt 0) {
            $clients[$client]['dd'] += $ddCheck
        }
        else {
            "Nothing to add to dd"
        }                                                    
                                                        
    }
}
Write-Debug "What is `$clients after loops"
$clients
$clients.GetEnumerator() | Sort-Object | ForEach-Object {
    "{0},{1},{2},{3}" -f ( $_.Name , $_.Value.pool, $_.Value.db, $_.Value.dd) | Out-File -FilePath $outFile -Append
    
}
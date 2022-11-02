$DebugPreference = "Continue"
$clients = @{
    Pepsi = @{
        db = '123'
        dd = '123'
        pool = '123','456','789'
    }
    Coke = @{
        db = '123'
        dd = '123'
        pool = '789','456','123'
    }
}

$client = 'RC'

$pool = '101','102','123' #works with a single item as well.
$db = '123','456'
$dd = '456','789'


if($clients[$client]) {
    #found a client match - check their $pool $db and $dd values for updates/changes?
    $poolCheck = $pool | Where-Object -FilterScript { $_ -notin $clients[$client]['pool']}
    if($poolcheck.Count -gt 0){
        $clients[$client]['pool'] += $poolCheck
    } else {
        "Nothing to add to pool"
    }

    #Do the same if statement for $dd and $db as you did for $pool...


} else {
    #no client, create new..
    $newClientData = @{
        db = [array]$db #even if they are single objects now, we want them to be arrays for later.
        dd = [array]$dd #even if they are single objects now, we want them to be arrays for later.
        pool = [array]$pool #even if they are single objects now, we want them to be arrays for later.
    }
    $clients.Add($client,$newClientData)
}

Write-Debug "RC"
$clients.RC
Write-Debug "Coke"
$clients.Coke
Write-Debug "Pepsi"
$clients.Pepsi
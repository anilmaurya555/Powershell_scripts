$data = Get-Content "C:\anil\scripts\client_with_.txt"
$ErrorActionPreference = 'SilentlyContinue'
foreach ( $client in $data ) {
                  $newclient1 = $client -replace '(.+?)_.+','$1'
                  $newclient2 = $newclient1 -replace '(.+?)2019.+','$1'
                  $newclient3 = $newclient2 -replace '(.+?)2020.+','$1'
                  $newclient3
                  }
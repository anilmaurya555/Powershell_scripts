$data = Get-Content "C:\anil\scripts\client_with_.txt"
$ErrorActionPreference = 'SilentlyContinue'
foreach ( $client in $data ) {
                  $newclient = $client.Substring(0, $client.IndexOf('_' ) )
                  $newclient
                  }
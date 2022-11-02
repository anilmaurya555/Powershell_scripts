 . ./cohesity-api 
### list agent info 
$agents = api get protectionSources | Where-Object { $_.protectionSource.name -eq 'Physical Servers' } 
foreach ($node in $agents.nodes){ 
     $name = $node.protectionSource.physicalProtectionSource.agents[0].name 
          if ($name -ieq 'mgmt213.sigi.us.selective.com' ) { 
                              "refreshing $name..." 
                             api post protectionSources/refresh/$($name[0].id) 
                             }
 }  
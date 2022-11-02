. ./cohesity-api 
apiauth -vip sbch-dp04br.selective.com -username maurya1 -domain sigi.us.selective.com
### list agent info 
$agents = api get protectionSources 
foreach ($node in $agents.nodes){ 
     $name = $node.protectionSource.name 
     $version = $node.protectionSource.physicalProtectionSource.agents[0].version 
     $name
 } 
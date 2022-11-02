### usage: ./protectedBy.ps1 -vip 192.168.1.198 -username admin -domain local -object myvm
### process commandline arguments

[CmdletBinding()]
                  param (
                  [Parameter(Mandatory = $True)][string]$vip ,
                  [Parameter(Mandatory = $True)][string]$username ,
                  [Parameter()][string]$domain = 'sigi.us.selective.com',
                  [Parameter(Mandatory = $True)][string]$object
                         )

### source the cohesity-api helper code
              . ./cohesity-api
              
### authenticate
apiauth -vip $vip -username $username -domain  $domain
$nodes = api get '/entitiesOfType?environmentTypes=kSQL&environmentTypes=kVMware&environmentTypes=kPhysical&environmentTypes=kOracle&oracleEntityTypes=kDatabase&physicalEntityTypes=kHost&physicalEntityTypes=kWindowsCluster&sqlEntityTypes=kInstance&sqlEntityTypes=kDatabase&sqlEntityTypes=kAAG&vmwareEntityTypes=kVirtualMachine&vmwareEntityTypes=kVirtualApp'
                        
                        foreach($node in  $nodes){
                                                 $name = $node.displayName
                                                 $sourceId = $node.id

                                                 # find matching node
                                                 if($name -eq $object ){
                                                                       write-host "refreshing $name..."

                                                                      # $node | fc
                                                                      # $sourceId

                                                                      api post protectionSources/refresh/$sourceId

                                                                       }

                                                     }





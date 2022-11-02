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

apiauth -vip $vip -username $username -domain $domain


# get protection jobs

$jobs = api get protectionJobs


# get root protection sources

$sources = api get protectionSources

$global:nodes = @()


# get flat list of protection source nodes

function 
get_nodes($obj){

              if($obj.PSObject.Properties['nodes']){

                                  foreach($node in  $obj.nodes){

                                                      get_nodes($node)

                                                              }

                                                   }else{

                                                        $global:nodes += $obj

                                                        }

                                                  }


foreach($source in $sources){

           get_nodes($source)

                        }


$foundNode = $false
$foundIds = @()

foreach($node in $global:nodes){

             $name = $node.protectionSource.name

             $sourceId = $node.protectionSource.id


               # find matching node

            if($name -eq $object ){

                                api post protectionSources/refresh/$($node.protectionSource.id)


                                 }

                  }


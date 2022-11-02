$lookuplist = get-content 'C:\anil\avamar list\mnbamr303p_0509_clients_with_bkp_details.txt'
$serverdates = @{}
$outfile = $(Join-Path -Path $PSScriptRoot -ChildPath mnbamr303p_0509_clients_details_$(get-date -UFormat '%Y-%m-%d-%H-%M-%S').txt)
foreach ( $lookup in $lookuplist){   ####3
                $arr = @()
                $arr = $lookup -split '\s+' -match '\S'
                $servers = Get-Content 'C:\anil\avamar list\mnbamr303p_0509_clients.txt'
                foreach ($server in $servers){ ###2
                                           
                                           if ($arr[1] -like "*$server*" -and $arr[11] -eq 2 -and $arr[7] -eq 1 ){    ###1

                                                  
                                                   
                                                   if ($server -notin $serverdates.keys){
                                                         $serverdates[$server]=@{}
                                                         $serverdates[$server]['createdate']=$arr[3]
                                                         $serverdates[$server]['expiredate']=$arr[4]
                                                         $serverdates[$server]['data']= [int64]$arr[6]
                                                         $serverdates[$server]['DD']= "mnbdd3302p"
                                                                                                                                      
                                                          } else {
                                                          $serverdates[$server]['createdate']=$arr[3]
                                                         $serverdates[$server]['expiredate']=$arr[4]
                                                         $serverdates[$server]['data'] += [int64]$arr[6]
                                                         

                                                                }

                                                                }  ####1
                                           

                              }   ####2

                              }    ####3

    "ServerName=======CreateDate==ExpiryDate=Data TB=DD====="| Out-File -FilePath $outFile -Append
    "======================================================="| Out-File -FilePath $outFile -Append
    $serverdates.GetEnumerator()|ForEach-Object {

    "{0,-15}  {1, -10}  {2,-10}  {3:n2}  {4,-10}" -f $_.name,$_.value.createdate,$_.value.expiredate,$($_.value.data/1024),$_.value.DD| Out-File -FilePath $outFile -Append

    }
   

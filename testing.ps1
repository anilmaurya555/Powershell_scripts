$ht = @{
    'Hcohesity01' = @{
        'Errors_reported'  = 8
        'total_backups'  = 603
        'backup_success' = 98.67
        'physical_size' = 384.82
        'logical_backup_size' = 15930.20
        'physical_size_consumed' = 180.82
        'perc_physical_size_consumed' = 46.99
        'IBMcos_size_consumed' = 140
        'per_IBMcos_size_consumed' = 40.46
        
        'percentge_change' = @{
        'server1'  = 4
        'server2'  = 5
        'server3' = 10
    }
    
    }
   'Hcohesity03' = @{
         'Errors_reported'  = 1
        'total_backups'  = 327
        'backup_success' = 99.69
        'physical_size' = 385.03
        'logical_backup_size' = 15908.70
        'physical_size_consumed' = 181.28
        'perc_physical_size_consumed' = 47.08
        'IBMcos_size_consumed' = 72
        'per_IBMcos_size_consumed' = 45.57
        
        'percentge_change' = @{
        'server1'  = 4
        'server2'  = 5
        'server3' = 10
        'server4' = 10
    }
    
    }
}
$ht.Hcohesity03.percentge_change.server4 = 20
foreach ( $nv in $ht.Hcohesity03.percentge_change.GetEnumerator()) {
$server5 += $nv.value
             }

$ht.Hcohesity03.percentge_change.server5 = $server5
#$ht['Feature1']['Feature2']['Change']
#$ht.Hcohesity03.percentge_change.GetEnumerator()|Sort-Object -Property name 
#$ht.Hcohesity03.percentge_change.server3
#$ht.Hcohesity03.percentge_change.keys
$ht.Hcohesity03.percentge_change.values
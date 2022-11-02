Get-VM cops-db02t|Get- Harddisk
Select Name,@{N="VM";E={$_.Parent.Name}},
    @{N="Datastore";E={$_.Filename.Split(']')[0].Trim('[')}},
    @{N="Cluster";E={Get-Cluster -VM $_.Parent.Name | Select -ExpandProperty Name}},
    DiskType,Persistence,CapacityGB
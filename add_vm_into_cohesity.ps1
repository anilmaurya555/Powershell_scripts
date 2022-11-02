ForEach ($system in Get-Content “test.txt”) 
{ 
.\vm_addition.ps1 -JobId 310 -VmNames $system -Mode Append 
} 

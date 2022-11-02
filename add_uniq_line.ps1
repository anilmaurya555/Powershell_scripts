 $content = get-content "c:\anil\scripts\input.txt"
$array = @()
foreach($line in $content){
    
    if($line -notin $array -and $line.contains('Skipped backing up')){
             
             $array += ($line -split "(?=due to)"|select -First 1 ) -replace "Skipped backing up ",""
        
    }
}
$array| Select-Object -Unique 
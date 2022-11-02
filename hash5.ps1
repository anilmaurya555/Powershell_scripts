$DebugPreference = "Continue"
$pools = '123','456','789','100'
$poolString = '123'
$poolArray = '123','789'


Write-Debug "Test 1 - Double quotes around variable in comparison."
#Won't match because of the extra space in our quotes for $poolString
if("$poolString " -notin $pools) {
    "Didn't find `$poolString value '$poolString ' in `$pools $pools"
} else {
    "Found `$poolString value $poolString in `$pools $pools"
}

Write-Debug "Test 2 - No quotes around variable in comparison"
#Will match because we removed the double quotes and it's a single item
if($poolString -notin $pools) {
    "Didn't find `$poolString value '$poolString' in `$pools $pools"
} else {
    "Found `$poolString value $poolString in `$pools $pools"
    $pools
}

Write-Debug "Test 3 - Comparing two array types with '-notin'."
if($poolArray -notin $poolArray){
    "Didn't find `$poolArray value(s) $poolArray in `$pools $pools"
} else {
    "Found `$poolArray value $poolArray in `$pools $pools"
}
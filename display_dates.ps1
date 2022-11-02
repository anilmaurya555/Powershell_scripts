$dates = ("2022-07-29","2022-07-28","2022-07-27")
function display($dates){
    $fmt = ""
    0..$($dates.Count - 1) | foreach {
        $fmt += "{$_,15}"
    }
    Write-Host ($fmt -f $dates)
}
display $dates 

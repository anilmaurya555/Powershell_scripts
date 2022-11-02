
    $d = get-date
    $lastDay = new-object DateTime($d.Year, $d.Month, [DateTime]::DaysInMonth($d.Year, $d.Month))
    $lastDay
    $diff = ([int] [DayOfWeek]::Friday) - ([int] $lastDay.DayOfWeek)
    if ($diff -ge 0) {
        $lastd = $lastDay.AddDays(- (7-$diff))
    }
    else
    {
        $lastd = $lastDay.AddDays($diff)
    }

 
 #Get-LastFridayOfMonth(Get-Date).toString("yyyy-M-dd")
 #$lastfriday= Get-LastFridayOfMonth(Get-Date)
$lastdate = get-date "$lastd" -format yyyy-M-dd
 $lastdate

     #if ( (get-date "$lastfriday" -format yyyy-M-dd) -eq (Get-Date -format yyyy-M-dd)){
                #$lastd 
               # }
# get-date ($Get-LastFridayOfMonth(Get-Date))
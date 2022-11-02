function Get-LastFridayOfMonth([DateTime] $d) {
    $lastDay = new-object DateTime($d.Year, $d.Month, [DateTime]::DaysInMonth($d.Year, $d.Month))
    $diff = ([int] [DayOfWeek]::Friday) - ([int] $lastDay.DayOfWeek)
    if ($diff -ge 0) {
        return $lastDay.AddDays(- (7-$diff))
    }
    else
    {
        return $lastDay.AddDays($diff)
    }
}
 
 #Get-LastFridayOfMonth(Get-Date).toString("yyyy-M-dd")
 $lastfriday= Get-LastFridayOfMonth(Get-Date)
 $lastd = get-date "$lastfriday" -format yyyy-M-dd
 $lastd

     if ( (get-date "$lastfriday" -format yyyy-M-dd) -eq (Get-Date -format yyyy-M-dd)){
                $lastd 
                }
# get-date ($Get-LastFridayOfMonth(Get-Date))
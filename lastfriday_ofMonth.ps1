#function Get-LastSaturdayOfMonth([DateTime] $d) {    
  #  $lastDay = new-object DateTime($d.Year, $d.Month, [DateTime]::DaysInMonth($d.Year, $d.Month))
  #  $diff = ([int] [DayOfWeek]::Saturday) - ([int] $lastDay.DayOfWeek)

    #if ($diff -ge 0) {
       # return $lastDay.AddDays(- (7-$diff))
    #}
    #else {
        #return $lastDay.AddDays($diff)
    #}    
#}
#$date1 = (Get-Date).AddDays(-20) 
#$date2 = (Get-Date).AddDays(1) 
#$date2 -gt $date1 
#$startdate = (Get-Date 2020-09-11).toString("yyyy-M-dd")
#$enddate   = (Get-Date 2020-11-14).toString("yyyy-M-dd")
#$today     = Get-Date -format yyyy-M-dd


#if($today -gt $startdate -and $today -eq $enddate){
    #Write-Output "Run script"
#}else{
  #  Write-Output "Date out of range"
#}
#first Sunday of a Month
#$date = Get-Date
#if ($date.Day -lt 7 -and $date.DayOfWeek -eq "Sunday") {$true} else {$false}
######
#%Now, let's use the .AddDays() method to subtract today's date from the date, to give us a pointer to the first of the month.

#$date.AddDays(-($date.Day-1))
#>Thursday, September 1, 2016 11:46:36 AM
#Finally, we can chain another .AddDays() to the end of this long string, to add the number of days to it that you'd like to. In your case, you'd like to find the seventh day of the month. We'll do that by adding six more days.

#$date.AddDays(-($date.Day-1)).AddDays(6)
#>Wednesday, September 7, 2016 11:48:15 AM
#
function Get-LastFridayOfMonth([DateTime] $d) {
    $lastDay = new-object DateTime($d.Year, $d.Month, [DateTime]::DaysInMonth($d.Year, $d.Month))
    $diff = ([int] [DayOfWeek]::Friday) - ([int]    $lastDay.DayOfWeek)
    if ($diff -ge 0) {
        return $lastDay.AddDays(- (7-$diff))
    }
    else
    {
        return $lastDay.AddDays($diff)
    }
}
#$date = (Get-Date).AddMonths(-1)
#$today     = Get-Date -format yyyy-M-dd
#$lastfriday = Get-LastFridayOfMonth(Get-Date).toString("yyyy-M-dd")
 #Get-LastFridayOfMonth(Get-Date)
 #  if ( $today -eq $lastfriday)
  #                 { write-host "Got it"
   #   
   ############worked #############3 
   #if ((Get-Date).Date -eq [DateTime]"11/06/2020") {write-host wow}
   ###############################below 
               
   $d = get-date
$nov = get-date "11/6/2020"
if ( $d.date -eq [DateTime]$nov) { write-host wow} else { write-host not_wow}
#### below work ########
#$Date1 = "10/18/2018 09:25:00"
#$Date2 = "01/09/2019 22:10:00"
  #if ( [DateTime]$Date1 -lt [DateTime]$Date2 ) { write-host wow } else {write-host not}
  ##### ##############333333333

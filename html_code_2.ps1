
##bgcolor="#92a8d1' for color column head f18973 for title color
function tdhead($data, $color){
    '<td colspan="1" bgcolor="#d5f4e6' + $color + '" valign="top" align="CENTER" border="0"><font size="2">' + $data + '</font></td>'
}
function td($data, $color, $wrap='', $align='LEFT'){
    '<td ' + $wrap + ' colspan="1" bgcolor="#92a8d1' + $color + '" valign="top" align="' + $align + '" border="0"><font size="2">' + $data + '</font></td>'
}


$html = '<html>'

$html += '<div style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;"><font face="Tahoma" size="+3" color="#000080">
<hr>

<br><br></div>'

$html += '<table align="center" border="1" cellpadding="4" cellspacing="0" style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;">
<tbody><tr><td colspan="21" align="CENTER" valign="TOP" bgcolor="#f18973"><font size="+1" color="#000000">Logical space usage</font></td></tr><tr bgcolor="#000000">'

$headings = @('Object Name',
              'Size (GB)', 
              'Enviornment')
              
foreach($heading in $headings){
    $html += td $heading 'CCCCCC' '' 'CENTER'
}
$html += '</tr>'
$nowrap = 'nowrap'



$html += "</table>                
</div>
</body>
</html>"


$html | Out-File -FilePath html2.html
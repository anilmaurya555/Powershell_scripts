
function tdhead($data, $color){
    '<td colspan="1" bgcolor="#' + $color + '" valign="top" align="CENTER" border="0"><font size="2">' + $data + '</font></td>'
}
function td($data, $color, $wrap='', $align='LEFT'){
    '<td ' + $wrap + ' colspan="1" bgcolor="#' + $color + '" valign="top" align="' + $align + '" border="0"><font size="2">' + $data + '</font></td>'
}
# top of html
#$prefixTitle = "($([string]::Join(", ", $prefix.ToUpper())))"

$html = '<html><div style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;"><font face="Tahoma" size="+3" color="#000080">
<center>Backup Job Summary Report<br>
<font size="+2">Backup Job Summary Report - ' + $prefixTitle + ' Daily Backup Report</font></center>
</font>
<hr>
Report generated on ' + (get-date) + '<br>
Cohesity Cluster: ' + $cluster.name + '<br>
Cohesity Version: ' + $cluster.clusterSoftwareVersion + '<br>
<br></div>'

$html += '<table align="center" border="0" cellpadding="4" cellspacing="1" style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;">
<tbody><tr><td colspan="21" align="CENTER" valign="TOP" bgcolor="#000080"><font size="+1" color="#FFFFFF">Summary</font></td></tr><tr bgcolor="#FFFFFF">'

$headings = @('Object Type',
              'Object Name', 
              'Database',
              'Registered Source',
              'Job Name',
              'Available Snapshots',
              'Latest Status',
              'Schedule Type',
              'Last Start Time',
              'Last End Time',
              'Logical MB',
              'Read MB',
              'Written MB',
              'Change %',
              'Failure Count',
              'Error Message')

foreach($heading in $headings){
    $html += td $heading 'CCCCCC' '' 'CENTER'
}
$html += '</tr>'
$nowrap = 'nowrap'


# end of html
$html += '</tbody></table><br>
<table align="center" border="1" cellpadding="4" cellspacing="0" style="font-family: Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size: small;">
<tbody>
<tr>
<td bgcolor="#9DCEF3" valign="top" align="center" border="0" width="100"><font size="1">Running</font></td>
<td bgcolor="#CC99FF" valign="top" align="center" border="0" width="100"><font size="1">Paused</font></td>
<td bgcolor="#CCFFCC" valign="top" align="center" border="0" width="100"><font size="1">Completed</font></td>
<td bgcolor="#F3F387" valign="top" align="center" border="0" width="100"><font size="1">Completed with warnings</font></td>
<td bgcolor="#F3BB76" valign="top" align="center" border="0" width="100"><font size="1">Cancelled</font></td>
<td bgcolor="#FF9292" valign="top" align="center" border="0" width="100"><font size="1">Failed</font></td>
<td bgcolor="#DAB0B0" valign="top" align="center" border="0" width="100"><font size="1">Change Rate &gt; 10%</font></td>
</tr>
</tbody>
</table>
</html>'

$outFilePath = join-path -Path $PSScriptRoot -ChildPath 'mytemplate.html'
$html | Out-File -FilePath 'mytemplate.html' -Encoding ascii
.$outFilePath
### usage: ./strikeReport.ps1 -vip mycluster -username myusername -domain mydomain.net -sendTo myuser@mydomain.net, anotheruser@mydomain.net -smtpServer 192.168.1.95 -sendFrom backupreport@mydomain.net

### process commandline arguments
[CmdletBinding()]

$html = '<html>
<head>
    <style>
        h1 {
            background-color:#0000ff;
            }
      
        p {
            color: #555555;
            font-family:Arial, Helvetica, sans-serif;
        }
        
        
        table {
            font-family: Arial, Helvetica, sans-serif;
            color: #333333;
            font-size: 0.75em;
            border-collapse: collapse;
            
        }
        tr {
            border: 1px solid #F1F1F1;
        }
        td,
        th {
            text-align: left;
            padding: 6px;
        }
        tr:nth-child(even) {
            background-color: #F1F1F1;
        }
    </style>
</head>
<body>
    
    </div>'




$html += '<div style="width:550px;margin-top: 15px; margin-bottom: 15px;"><span style="font-size:2em;"><font face="Tahoma" size="+2" color="D35400"> 
<left>Backup Summary Reports From ALL cluster<br>
</div>'


$title = "Backup Summary Report "
$html += '<div style="width:550px;background-color: #0000FF;">

 <left>'+ $title +'<br>
  </div>'


################stats#########
################change rate ##########3

$fileName = "./Cohesity_summary_report.html"
$html | out-file $fileName


[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Windows.Forms.Application]::EnableVisualStyles() 
 
$Form = New-Object System.Windows.Forms.Form 
#$Form.Size = New-Object System.Drawing.Size(430,300) 
$Form.Size = New-Object System.Drawing.Size(630,500)
#$Form.AutoSize = $true
$Form.StartPosition = "CenterScreen" 
$Form.FormBorderStyle = 'Fixed3D' 
$Form.Text = "Anil's GUI"

$fontHeader = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold) 

$label1 = New-Object System.Windows.Forms.Label 
$label1.Location = New-Object System.Drawing.Size(25,15) 
$label1.AutoSize = $true 
#$label1.Text = " Pick your option"
$label1.Text = "My Work Area"
$label1.Font = $fontHeader

$buttonJoin1= New-Object System.Windows.Forms.Button 
$buttonJoin1.Location = New-Object System.Drawing.Size(75,200) 
$buttonJoin1.autoSize = $true
$buttonJoin1.text = "Join Domain" 
$buttonJoin1.add_Click({JoinDomain}) 

$buttonJoin2 = New-Object System.Windows.Forms.Button 
$buttonJoin2.Location = New-Object System.Drawing.Size(80,200) 
$buttonJoin2.AutoSize = $true
$buttonJoin2.Text = "Join Domain" 
$buttonJoin2.Add_Click({JoinDomain}) 

$Form.Controls.Add($buttonJoin1) 
$Form.Controls.Add($buttonJoin2)

$Form.ShowDialog()
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Windows.Forms.Application]::EnableVisualStyles() 
 
Function JoinDomain 
{ 
    Write-Host "Subsidary Code = " $field1.Text
    Write-Host "Laptop / Desktop = " $field2.Text
    Write-Host "Username = " $field3.Text
    Write-Host "Password Code = " $field4.Text
    $Form.Close()
} 
 
$Form = New-Object System.Windows.Forms.Form 
#$Form.Size = New-Object System.Drawing.Size(430,300) 
$Form.Size = New-Object System.Drawing.Size(630,500)
#$Form.AutoSize = $true
$Form.StartPosition = "CenterScreen" 
$Form.FormBorderStyle = 'Fixed3D' 
$Form.Text = "Join Domain" 

$fontHeader = New-Object System.Drawing.Font("Arial",12,[System.Drawing.FontStyle]::Bold) 

$label1 = New-Object System.Windows.Forms.Label 
$label1.Location = New-Object System.Drawing.Size(25,15) 
$label1.AutoSize = $true 
#$label1.Text = "Join Laptop/PC to domain and add to Proper OU"
$label1.Text = "My Work Area"
$label1.Font = $fontHeader

$label2 = New-Object System.Windows.Forms.Label 
$label2.Location = New-Object System.Drawing.Size(25,50) 
$label2.AutoSize = $true 
$label2.Text = "Enter 3 Letter Subsidary Code:" 

$field1 = New-Object Windows.Forms.TextBox
$field1.Location = New-Object Drawing.Point 225,50
$field1.Size = New-Object Drawing.Point 50,30
 
$label3 = New-Object System.Windows.Forms.Label 
$label3.Location = New-Object System.Drawing.Size(25,75) 
$label3.AutoSize = $true 
$label3.Text = "Enter 1 for Laptop or 2 for Desktop:" 

$field2 = New-Object Windows.Forms.TextBox
$field2.Location = New-Object Drawing.Point 225,75
$field2.Size = New-Object Drawing.Point 50,30

$label4 = New-Object System.Windows.Forms.Label 
$label4.Location = New-Object System.Drawing.Size(25,100) 
$label4.AutoSize = $true 
$label4.Text = "Enter Your Credentials" 

$label5 = New-Object System.Windows.Forms.Label 
$label5.Location = New-Object System.Drawing.Size(50,125) 
$label5.AutoSize = $true 
$label5.Text = "Username:" 

$field3 = New-Object Windows.Forms.TextBox
$field3.Location = New-Object Drawing.Point 225,125
$field3.Size = New-Object Drawing.Point 150,30

$label6 = New-Object System.Windows.Forms.Label 
$label6.Location = New-Object System.Drawing.Size(50,150) 
$label6.AutoSize = $true 
$label6.Text = "Password:" 

$field4 = New-Object Windows.Forms.TextBox
$field4.Location = New-Object Drawing.Point 225,150
$field4.Size = New-Object Drawing.Point 150,30

$buttonJoin = New-Object System.Windows.Forms.Button 
$buttonJoin.Location = New-Object System.Drawing.Size(175,200) 
$buttonJoin.AutoSize = $true
$buttonJoin.Text = "Join Domain" 
$buttonJoin.Add_Click({JoinDomain}) 

$Form.Controls.Add($label1) 
$Form.Controls.Add($label2) 
$Form.Controls.Add($field1)
$Form.Controls.Add($label3) 
$Form.Controls.Add($field2)
$Form.Controls.Add($label4) 
$Form.Controls.Add($label5) 
$Form.Controls.Add($field3)
$Form.Controls.Add($label6) 
$Form.Controls.Add($field4)
$Form.Controls.Add($buttonJoin) 

$Form.ShowDialog()
WScript.Echo "You entered: " & getName()
Function getName()
Dim tempName
tempName = ""
Do While tempName = ""
tempName = InputBox("Enter your name:")
Loop
getName = tempName
End Function
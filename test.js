currArray = new Array()
for (x = 0; x < 10; x++) {
currArray[x] = "Initial"
}
counter = 0
for (i in currArray) {
WScript.Echo("Value " + counter + " equals: " + currArray[i])
counter++
}
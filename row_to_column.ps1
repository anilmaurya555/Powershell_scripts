$src = "C:\Ephemeral\input_file.txt"
$inData = New-Object -TypeName System.IO.StreamReader -ArgumentList $src

$lineNum = 0  # initialize the counters
$clientsTag = 'succeeded clients list'
$blankLine = [regex]"^\s*$"

# begin reading and processing the input file
$results = while (-not $inData.EndOfStream)
{
    # collect atomic units
    $ar = New-Object -TypeName System.Collections.ArrayList
    do {
        $line = $inData.ReadLine()
        $lineNum++
        Write-Verbose "Reading line $lineNum|$line"
        [void]$ar.Add($line)

    } until ($line -match $blankLine)

    # process atomic units into records
    $hash = @{}
    foreach ($item in $ar)
    {
        if ($item.Length -gt 0 -and $item.Contains(": "))
        {
            # normal field
            $key, $value = $item.TrimStart() -Split ": "
            $hash[$key] = $value.TrimEnd(";, ")
        } else {
            # continutaion field
            # dump previous record
            [PSCustomObject]$hash
            # additional client field
            $hash[$clientsTag] = $item.TrimStart().TrimEnd(";, ")
        }
    }
} 

$inData.Close()

$results | select  "job id", @{N="Client";E={$_.$clientsTag}}, "job state",
    @{n="Status";E={$_."completion status"}},"start time", "end time",
    "host" 
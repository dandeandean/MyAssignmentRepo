function ConvertTo-DoubleOrString($item) {
    if (($item -eq ' ') -or ($item -eq '')) {
        return $null
    }
    try {
        $item = [double] $item
    }
    catch  {
        $item = [string] $item
    }
    return $item
}

function Select-ByType($array, $type){
    $out = ($array | Where-Object { $_ -is [type]$type })
    return $out
}

function Format-Args($argv) {
    if ($argv.count -ne 3) {
        throw "Usage: Sort.ps1 <File> <Type> <Direction>"
    }
    $filepath = $argv[0]
    $type = $argv[1].ToString().ToLower()
    $direction = $argv[2].ToString().ToLower()
    if (-not (Test-Path $filepath)) {
        throw "The path: $filepath does not exist."
    }
    if ( -not( @('alpha', 'both', 'numeric', 'a', 'b', 'n') -contains $type)) {
        throw "Please choose '(a)lpha', '(n)umeric', or '(b)oth'. Invalid type: $type." 
    }
    switch ($type[0]) {
        "a" { $filter = "string" }
        "n" { $filter = "double" }
        default { $filter = "object" }
    }
    if ( -not( @('ascending', 'descending', 'a', 'd') -contains $direction)) {
        throw "Please choose '(a)scending' '(d)escending'. Invalid direction: $direction." 
    }
    return @($filepath, $filter, $direction)
}


function Get-Contents($filepath, $filter) {
    <#
        .DESCRIPTION
        Get-Contents takes a filepath & filter and returns the filter applied to the contents of the file in an array.
        If it fails to split the items by comma, then it returns an empty array.
    #>
    $items = Get-Content -Path $filepath 
    try {    
        $items = $items.Split(",") -replace " ", ""
    }
    catch {
        return @()
    }
    $itemsFiltered = $items | ForEach-Object{ConvertTo-DoubleOrString($_)} 
    $outFiltered = Select-ByType $itemsFiltered $filter
    return $outFiltered
}

function Set-ItemsTyped($items, $direction, $filter) {
    <#
    .Description
    Set-Items takes the items, direction & and filter and returns 
    #>
    if ($filter -eq "string") {
        <# This is all very bad
        # Also very flimsy b/c we don't account for «» or „“ ... 
        # Actually there are a lot of diffent quotation marks
        # see: https://en.wikipedia.org/wiki/Quotation_mark
        #>
        $hash = @{}
        foreach ($item in $items) {
            $value = @($item)
            if ($item -match "'*'"){
                $itemStripped = $item.Replace( "'" , "")
                if ($hash.ContainsKey($itemStripped)){
                    $hash[$item] += $value
                }
                else{
                    $hash.Add($itemStripped,@($item))
                }
            }
            elseif ($item -match '"*"'){
                $itemStripped = $item.Replace( '"' , "")
                if ($hash.ContainsKey($itemStripped)){
                    $hash[$item] += $value
                }
                else {
                    $hash.Add($itemStripped,@($item))
                }
            } else {
                if ($hash.ContainsKey($item)){
                    $hash[$item] += $value
                }
                else{
                $hash.Add($item,$value)
                }
            }
        }
        $out = @()
        ($hash.GetEnumerator() | Sort-Object -Descending:($direction[0] -eq 'd') ) | ForEach-Object {
            $out += $_.Value
        }
        return $out
    }
    $sortedItems = $items | Sort-Object -Descending:($direction[0] -eq 'd')
    return $sortedItems
}

##### Main Functionality ######
$filepath, $filter, $direction = Format-Args $args
$itemsAlpha = Get-Contents $filepath "string"
$itemsNumeric = Get-Contents $filepath "double"
$sortedNumeric = Set-ItemsTyped $itemsNumeric $direction "double"
$sortedAlpha = Set-ItemsTyped $itemsAlpha $direction "string"
switch ($filter[0]) {
    "s" { #from string
        $items = $sortedAlpha 
    }
    "d" { #from double
        $items = $sortedNumeric 
    }
    Default {
        $items = $sortedNumeric + $sortedAlpha
    }
}
Write-Host ($items -Join ",")

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


function Get-Contents($filepath) {
    <#
    .Description
    Get-Contents takes the filepath & returns a list of @(alpha , numeric) 
    based on whether or not we could cast each item into a numeric type (double) or not
    #>        
    # Maybe this should just return alpha & numeric as a tuple
    $items = Get-Content -Path $filepath 
    try {    
        $items = $items.Split(",")
    }
    catch {
        return @()
    }
    $outs = @()
    foreach ($item in $items ) {
        $outs += ConvertTo-DoubleOrString($item)
    }
    #FIXME: adding to an array probably is very slow 
    #try something like this
    # $items = $items | ForEach-Object{ConvertTo-DoubleOrString($_)}
    # Write-Host  ($items -eq $outs)
    $itemsAlpha = Select-ByType $outs "string" 
    $itemsNumeric = Select-ByType $outs "double"

    return @($itemsAlpha, $itemsNumeric)
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


$filepath, $filter, $direction = Format-Args $args

$itemsAlpha, $itemsNumeric = Get-Contents $filepath
switch ($filter[0]) {
    "s" { #from string
        $items = $itemsAlpha 
        $sortedItems = Set-ItemsTyped $items $direction "string"
    }
    "d" {#from double
        $items = $itemsNumeric 
        $sortedItems = Set-ItemsTyped $items $direction "double"
    }
    Default {
        $sortedN = Set-ItemsTyped $itemsNumeric $direction "double"
        $sortedA = Set-ItemsTyped $itemsAlpha $direction "string"
        $sortedItems = $sortedN + $sortedA
    }
}
Write-Host $sortedItems

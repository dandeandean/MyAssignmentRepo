
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

function ConvertTo-DoubleOrString($item) {
    <#
        .DESCRIPTION
        ConvertTo-DoubleOrString attempts to convert $item to a double, then to a string if that fails
    #>
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
function Get-ContentsTyped($filepath, $filter) {
    <#
        .DESCRIPTION
        Get-ContentsTyped takes a filepath & filter and returns the filter applied to the contents of the file in an array.
        If it fails to split the items by comma, then it returns an empty array.
    #>
    $items = Get-Content -Path $filepath 
    try {    
        $items = ($items.Split(",")).Trim() 
    }
    catch {
        return @()
    }
    $itemsCasted = $items | ForEach-Object{ConvertTo-DoubleOrString($_)} 
    $itemsFiltered = ($itemsCasted | Where-Object { $_ -is [type]$filter })
    return $itemsFiltered
}

function Set-AlphaSorted($items, $direction) {
    <#
        .DESCRIPTION
        Set-AlphaSorted takes an array of strings and sorts them ignoring 
        anything in the form "*" and '*'
    #>
        $hash = @{}
        foreach ($item in $items) {
            $value = @($item)
            if ($item -match "'*'"){
                $itemStripped = $item.Replace( "'" , "")
                $hash[$itemStripped] += $value
            }
            elseif ($item -match '"*"'){
                $itemStripped = $item.Replace( '"' , "")
                $hash[$itemStripped] += $value
            } else {
                $hash[$item] += $value
            }
        }
        $out = @()
        ($hash.GetEnumerator() | Sort-Object -Descending:($direction[0] -eq 'd') ) | ForEach-Object {
            $out += $_.Value
        }
        return $out
}

function Set-NumericSorted($items, $direction) {
    <#
        .DESCRIPTION
        Set-NumericSorted takes an array of doubles and sorts them in ascending or descending $direction
    #>
    $sortedItems = $items | Sort-Object -Descending:($direction[0] -eq 'd')
    return $sortedItems
}

##### Main Functionality ######
$filepath, $filter, $direction = Format-Args $args
$itemsAlpha = Get-ContentsTyped $filepath "string"
$itemsNumeric = Get-ContentsTyped $filepath "double"
$sortedNumeric = Set-NumericSorted $itemsNumeric $direction
$sortedAlpha = Set-AlphaSorted $itemsAlpha $direction
switch ($filter[0]) {
    "s" { #string
        $items = $sortedAlpha 
    }
    "d" { #double
        $items = $sortedNumeric 
    }
    Default {
        $items = $sortedNumeric + $sortedAlpha
    }
}
Write-Host ($items -Join ",")

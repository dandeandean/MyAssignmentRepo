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
        $items = $items.Split(",")
    }
    catch {
        return @()
    }
    $itemsFiltered = $items | ForEach-Object{ConvertTo-DoubleOrString($_)} 
    $outFiltered = Select-ByType $itemsFiltered $filter
    return $outFiltered
}

function Set-Items($items, $direction) {
    $sortedItems = $items | Sort-Object -Descending:($direction[0] -eq 'd')
    return $sortedItems
}


$filepath, $filter, $direction = Format-Args $args
$items = Get-Contents $filepath $filter
$sortedItems = $items | Sort-Object -Descending:($direction[0] -eq 'd')
Write-Host ($sortedItems -Join ", ")
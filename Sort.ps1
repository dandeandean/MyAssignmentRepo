function SmartCast($item) {
    try {
        $item = [double] $item
    }
    catch  {
        # Not strictly necessary
        $item = [string] $item
    }
    return $item
}

function FilterByType($array, $type){
    $out = ($array | Where-Object { $_ -is [type]$type })
    return $out
}

function ParseArgs($argv) {
    if ($args.count -ne 3) {
        throw "Usage: Sort.ps1 <File> <Type> <Direction>"
    }
    $script:filepath = $argv[0]
    $script:type = $argv[1].ToString().ToLower()
    $script:direction = $argv[2].ToString().ToLower()
    if (-not (Test-Path $filepath)) {
        throw "The path: $filepath does not exist."
    }
    if ( -not( @('alpha', 'both', 'numeric', 'a', 'b', 'n') -contains $type)) {
        throw "Please choose '(a)lpha', '(n)umeric', or '(b)oth'. Invalid type: $type." 
    }
    switch ($type[0]) {
        "a" { $script:filter = "string" }
        "n" { $script:filter = "double" }
        default { $script:filter = "object" }
    }
    if ( -not( @('ascending', 'descending', 'a', 'd') -contains $direction)) {
        throw "Please choose '(a)scending' '(d)escending'. Invalid direction: $direction." 
    }
}

function ParseFile($filepath, $filter) {
    # Maybe this should just return alpha & numeric as a tuple
    $items = Get-Content -Path $filepath 
    $items = $items.Split(",")
    $outs = @()
    foreach ($item in $items ) {
        $outs += SmartCast($item)
    }
    $outFiltered = FilterByType $outs $filter
    return $outFiltered
}

function SwitchSort($items, $direction) {
switch ($direction[0]) {
    "d" {   
        $sortedItems = $items | Sort-Object -Descending
      }
    Default {
        $sortedItems = $items | Sort-Object
    }
}
    return $sortedItems
}

ParseArgs $args

$parsedItems = ParseFile $filepath $filter

$sortedItems = SwitchSort $parsedItems $direction

Write-Host $sortedItems
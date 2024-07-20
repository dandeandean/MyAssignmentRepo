if ($args.count -ne 3) {
    throw "Usage: Sort.ps1 <File> <Type> <Direction>"
}
$filepath = $args[0]
$type = $args[1].ToString().ToLower()
$direction = $args[2].ToString().ToLower()
# TODO: look into using param for this section
if (-not (Test-Path $filepath)) {
    throw "The path: $filepath does not exist."
}
if ( -not( @('alpha','both','numeric','a','b','n') -contains $type)) {
    throw "Please choose '(a)lpha', '(n)umeric', or '(b)oth'. Invalid type: $type." 
}
switch ($type[0]) {
    "a" { $filter = "string" }
    "n" { $filter = "double" }
    default { $filter = "object" }
}
if ( -not( @('ascending','descending','a','d') -contains $direction)) {
    throw "Please choose '(a)scending' '(d)escending'. Invalid direction: $direction." 
}

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
    #Write-Host $out
    return $out
}


#TODO: Fix this whole block, should probably be a one-liner
$items =  Get-Content -Path $filepath 
$items = $items.Split(",")
$outs = @()
foreach ($item in $items ){
    $outs += SmartCast($item)
}
$outFiltered = FilterByType $outs $filter
#FIXME
switch ($direction[0]) {
    "d" {   
        $outFiltered = $outFiltered | Sort-Object -Descending
      }
    Default {
        $outFiltered = $outFiltered | Sort-Object
    }
}
Write-Host $outFiltered
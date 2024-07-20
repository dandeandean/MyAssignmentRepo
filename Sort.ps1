if ($args.count -ne 3) {
    throw "Usage: Sort.ps1 <File> <Type> <Direction>"
}
$filepath = $args[0]
$type = $args[1]
$direction = $args[2]
if (-not (Test-Path $filepath)) {
    throw "The path: $filepath does not exist."
}
if ( -not( @('alpha','both','numeric') -contains $type)) {
    throw "Please choose 'alpha', 'numeric', or 'both'. Invalid type: $type." 
}
if ( -not( @('ascending','descending') -contains $direction)) {
    throw "Please choose 'ascending' 'descending'. Invalid direction: $direction." 
}

Import-Csv -Path $filepath
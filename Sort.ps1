if ($args.count -ne 3) {
    throw "Usage: Sort.ps1 <File> <Type> <Direction>"
}

open $args[0]
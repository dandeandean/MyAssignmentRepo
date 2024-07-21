# MyAssignmentRepo
## Goal
Write a PowerShell script that reads the contents of a file with comma separated values from disk and prints the numeric and/or alphabetic values from the file depending on what the user requests. 

Specifically:

Takes 3 parameters:
- Path to the file on disk
- String value which defines the type of sorted values requested. Valid values are: "alpha", "numeric", "both"
- String value which defines the sort order. Valid values are: "ascending", "descending"

## Sample inputs and outputs

```PowerShell
sample1.txt: "1,4,6,7,3,2,1.5"
input: MyApp.ps1 "sample1.txt" "numeric" "ascending"
expected output: "1,1.5,2,3,4,6,7"
input: MyApp.ps1 "sample1.txt" "numeric" "descending"
expected output: "7,6,4,3,2,1.5,1"
```
```
sample2.txt: "11, 12, 1e10, 'c', b, 'a', 15, 21, '50'"
input: MyApp.ps1 "sample2.txt" "numeric" "ascending"
expected output: "11, 12, 15, 21, 10000000000"
input: MyApp.ps1 "sample2.txt" "alpha" "ascending"
expected output: "'50', 'a', b, 'c'"
input: MyApp.ps1 "sample2.txt" "both" "ascending"
expected output: "11, 12, 15, 21, 10000000000, '50', 'a', b, 'c'"
```

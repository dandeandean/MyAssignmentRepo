import os, subprocess, sys
def sortps1(filepath: str, typ: str, direction: str ) -> None:
    print(f"Testing ({filepath=},{typ=},{direction=}):")
    if ("Sort.ps1" not in os.listdir()):
        print("Something horrible happened!")
        return 
    p = subprocess.Popen(
        ['pwsh','Sort.ps1',filepath,typ,direction],
        stdout=sys.stdout)
    p_out, p_err = p.communicate()
    if p_out : print(p_out)
    if p_err : print(p_err)

if __name__ == "__main__":
    sortps1("samples/sample0.txt","numeric","descending")
    sortps1("samples/sample0.txt","alpha","ascending")
    sortps1("samples/sample1.txt","numeric","ascending")
    sortps1("samples/sample1.txt","both","descending")
    sortps1("samples/sample2.txt","alpha","ascending")
    sortps1("samples/sample2.txt","numeric","descending")
    sortps1("samples/sample2.txt","both","ascending")
    # Should be nothing
    sortps1("samples/sample-nothing.txt","numeric","descending")
    sortps1("samples/sample-empty.txt","numeric","descending")

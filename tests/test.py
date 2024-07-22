import os, subprocess, sys
def sortps1(filepath: str, type: str, direction: str ) -> None:
    if ("Sort.ps1" not in os.listdir()):
        print("Something horrible happened!")
        return 
    p = subprocess.Popen(
        ['pwsh','Sort.ps1',filepath,type,direction],
        stdout=sys.stdout)
    p_out, p_err = p.communicate()
    print(p_out,p_err)



if __name__ == "__main__":
    sortps1("samples/sample1.txt","numeric","descending")
    sortps1("samples/sample2.txt","numeric","descending")
    sortps1("samples/sample-empty.txt","numeric","descending")
    sortps1("samples/sample-nothing.txt","numeric","descending")

import os, subprocess
def sortps1(filepath: str, typ: str, direction: str ) -> str|None:
    #print(f"Testing ({filepath=},{typ=},{direction=}):")
    if ("Sort.ps1" not in os.listdir()):
        print("Something horrible happened!")
        return
    return subprocess.check_output(['pwsh','Sort.ps1',filepath,typ,direction]).decode().replace("\n","")

def test_sample0():
    assert sortps1("samples/sample0.txt","both","ascending") == "1,1,2,3,\"a\",'a',a,'b',b,\"b\",c"
    assert sortps1("samples/sample0.txt","both","descending") == "3,2,1,1,c,'b',b,\"b\",\"a\",'a',a"
    assert sortps1("samples/sample0.txt","n","a") == "1,1,2,3"
    assert sortps1("samples/sample0.txt","n","d") == "3,2,1,1"

def test_sample1():
    assert sortps1("samples/sample1.txt","numeric","ascending") == "1,1.5,2,3,4,6,7"
    assert sortps1("samples/sample1.txt","numeric","descending") == "7,6,4,3,2,1.5,1"
    assert sortps1("samples/sample1.txt","alpha","ascending") == ""

if __name__ == "__main__":
    print(sortps1("samples/sample0.txt","alpha","ascending"))
    # sortps1("samples/sample1.txt","both","descending")
    # sortps1("samples/sample2.txt","alpha","ascending")
    # sortps1("samples/sample2.txt","numeric","descending")
    # sortps1("samples/sample2.txt","both","ascending")
    # # Should be nothing
    # sortps1("samples/sample-nothing.txt","numeric","descending")
    # sortps1("samples/sample-empty.txt","numeric","descending")

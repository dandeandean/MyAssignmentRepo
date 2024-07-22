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
    assert sortps1("samples/sample0.txt","a","a") == "\"a\",'a',a,'b',b,\"b\",c"
    assert sortps1("samples/sample0.txt","a","d") == "c,'b',b,\"b\",\"a\",'a',a"

def test_sample1():
    assert sortps1("samples/sample1.txt","numeric","ascending")  == sortps1("samples/sample1.txt","b","ascending")== "1,1.5,2,3,4,6,7"
    assert sortps1("samples/sample1.txt","numeric","descending")  == sortps1("samples/sample1.txt","b","d") == "7,6,4,3,2,1.5,1"
    assert sortps1("samples/sample1.txt","a","d")==sortps1("samples/sample1.txt","alpha","ascending") == ""

def test_sample2():
    assert sortps1("samples/sample2.txt","b","a") == "11,12,15,21,10000000000,'50','a',b,'c'"
    assert sortps1("samples/sample2.txt","b","d") == "10000000000,21,15,12,11,'c',b,'a','50'"
    assert sortps1("samples/sample2.txt","n","a") == "11,12,15,21,10000000000"
    assert sortps1("samples/sample2.txt","n","d") == "10000000000,21,15,12,11"
    assert sortps1("samples/sample2.txt","a","a") == "'50','a',b,'c'"
    assert sortps1("samples/sample2.txt","a","d") == "'c',b,'a','50'"

def test_sample3():
    assert sortps1("samples/sample3.txt","b","a") == "'aaron',barry,\"carrie\",\"da nny\",'earl'"
    assert sortps1("samples/sample3.txt","b","d") == "'earl',\"da nny\",\"carrie\",barry,'aaron'"
    assert sortps1("samples/sample3.txt","n","a") == ""
    assert sortps1("samples/sample3.txt","n","d") == ""

def test_void():
    assert sortps1("samples/sample-empty.txt","b","a") == ""
    assert sortps1("samples/sample-nothing.txt","b","a") == ""
    assert sortps1("samples/sample-shells.txt","b","a") == "\"\",\"\",'',''"

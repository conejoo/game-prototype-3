from pathlib import Path
import json, subprocess, zipfile, io
ROOT=Path(__file__).resolve().parents[4]
OUT=ROOT/'builds/testing/AD014/prepaint-03a6e989'
assert OUT.is_relative_to(ROOT/'builds/testing/AD014') and not OUT.exists()
data=subprocess.run(['git','-c',f'safe.directory={ROOT.as_posix()}','archive','--format=zip','HEAD','game','tools'],cwd=ROOT,capture_output=True,check=True).stdout
with zipfile.ZipFile(io.BytesIO(data)) as archive:
    for item in archive.infolist():
        assert (OUT/item.filename).resolve().is_relative_to(OUT)
    archive.extractall(OUT)
print(OUT)

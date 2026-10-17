"""Große offizielle Dateien in prüfbaren HTTP-Bereichen herunterladen."""
import argparse
import concurrent.futures
import hashlib
import time
import urllib.request
from pathlib import Path

def main():
    p=argparse.ArgumentParser();p.add_argument("--url",required=True);p.add_argument("--out",type=Path,required=True)
    p.add_argument("--size",type=int,required=True);p.add_argument("--sha256",required=True);p.add_argument("--workers",type=int,default=4)
    a=p.parse_args();a.out.parent.mkdir(parents=True,exist_ok=True)
    temp=a.out.with_suffix(a.out.suffix+".part")
    with temp.open("wb") as stream:stream.truncate(a.size)
    chunk=4*1024*1024
    def fetch(start):
        end=min(a.size-1,start+chunk-1)
        for attempt in range(4):
            try:
                req=urllib.request.Request(a.url,headers={"Range":f"bytes={start}-{end}","User-Agent":"Sonnenhain-AssetSetup/1.0"})
                with urllib.request.urlopen(req,timeout=60) as response:
                    if response.status!=206:raise RuntimeError(f"HTTP {response.status}, range ignored")
                    data=response.read()
                if len(data)!=end-start+1:raise RuntimeError("Range length differs")
                with temp.open("r+b") as stream:stream.seek(start);stream.write(data)
                return len(data)
            except Exception:
                if attempt==3:raise
                time.sleep(1+attempt)
    received=0;reported=0
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.workers) as pool:
        for count in pool.map(fetch,range(0,a.size,chunk)):
            received+=count
            if received-reported>=128*1024*1024 or received==a.size:
                print(f"{a.out.name}: {received/1024**2:.0f}/{a.size/1024**2:.0f} MiB",flush=True);reported=received
    digest=hashlib.file_digest(temp.open("rb"),"sha256").hexdigest()
    if digest.lower()!=a.sha256.lower():raise RuntimeError(f"Hash mismatch: {digest}")
    temp.replace(a.out);print("SHA256_OK",a.out,flush=True)
if __name__=="__main__":main()

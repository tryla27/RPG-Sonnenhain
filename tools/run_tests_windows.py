"""Windows-Gegenstück der vorhandenen Bash-Prüfauswahl; prüft auch SCRIPT ERROR."""
import argparse
import concurrent.futures
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
def main():
    parser=argparse.ArgumentParser();parser.add_argument("--godot",required=True);parser.add_argument("--jobs",type=int,default=4)
    args=parser.parse_args();logs=ROOT/"build/quality-test-logs";logs.mkdir(parents=True,exist_ok=True)
    content=subprocess.run([sys.executable,str(ROOT/"tools/check_content.py")],cwd=ROOT,capture_output=True)
    (logs/"content.log").write_bytes(content.stdout+content.stderr)
    if content.returncode:print("FAIL Inhaltsprüfung",flush=True);return 1
    excluded={"check_party_xp_network.gd","check_boss_head_save_network.gd","check_server_save_network.gd","check_app_controls.gd"}
    tests=sorted(p for folder in (ROOT/"tools",ROOT/"tests") for p in folder.rglob("check_*.gd") if p.name not in excluded)
    def run(path):
        relative=path.relative_to(ROOT).as_posix();log=logs/(relative.replace("/","_")+".log")
        try:
            result=subprocess.run([args.godot,"--headless","--path",str(ROOT),"--script","res://"+relative],cwd=ROOT,capture_output=True,timeout=180)
            output=result.stdout+result.stderr;log.write_bytes(output)
            # Dieselbe Fehlerregel wie run_all_tests.sh/CI. Engine-Meldungen
            # (etwa bestehende Ressourcenfreigabe-Warnungen) bleiben im Log.
            okay=result.returncode==0 and b"SCRIPT ERROR:" not in output
        except subprocess.TimeoutExpired as exc:
            log.write_bytes((exc.stdout or b"")+(exc.stderr or b"")+b"\nTIMEOUT");okay=False
        if not okay:print("FAIL",relative,flush=True)
        return okay,relative
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:results=list(pool.map(run,tests))
    results.append(run(ROOT/"tools/check_party_xp_network.gd"))
    # Diese Prüfung schreibt die gemeinsame Touch-Konfiguration. Sie läuft
    # isoliert, damit andere App-Prüfungen ihren Zustand nicht beeinflussen.
    results.append(run(ROOT/"tests/ui/check_app_controls.gd"))
    failed=[name for okay,name in results if not okay]
    print(f"TESTS_COMPLETE {len(results)-len(failed)} bestanden, {len(failed)} fehlgeschlagen",flush=True)
    print("Logs:",logs,flush=True)
    return bool(failed)
if __name__=="__main__":raise SystemExit(main())

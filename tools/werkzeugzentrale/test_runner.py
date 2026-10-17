"""Echte Prozesse prüfen Grenzen, Kindprozessabbruch und fail-closed-Kostenregeln."""
import contextlib
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import threading
import time
import unittest
import unittest.mock

import hub
import runner


def process_alive(pid):
    if os.name == "nt":
        import ctypes
        from ctypes import wintypes as w
        api = ctypes.WinDLL("kernel32", use_last_error=True)
        api.OpenProcess.argtypes, api.OpenProcess.restype = [w.DWORD, w.BOOL, w.DWORD], w.HANDLE
        api.GetExitCodeProcess.argtypes = [w.HANDLE, ctypes.POINTER(w.DWORD)]
        api.CloseHandle.argtypes = [w.HANDLE]
        handle = api.OpenProcess(0x1000, False, pid)
        if not handle:
            return False
        try:
            code = w.DWORD()
            return bool(api.GetExitCodeProcess(handle, ctypes.byref(code))) and code.value == 259
        finally:
            api.CloseHandle(handle)
    try:
        os.kill(pid, 0)
        stat = Path(f"/proc/{pid}/stat")
        return not stat.exists() or stat.read_text().split()[2] != "Z"
    except ProcessLookupError:
        return False


class RunnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sonnenhain hub test ")
        self.home = Path(self.temp.name)
        self.addCleanup(self.temp.cleanup)

    def recipe(self, code="print('OK')", timeout=10):
        return {"name": "probe", "project": str(self.home), "timeout": timeout,
                "steps": [{"id": "probe", "commands": [[sys.executable, "-c", code]],
                           "cwd": str(self.home), "cost_class": "local_compute", "inputs": [],
                           "timeout": 10, "detached": False, "retries": 0}]}

    def test_real_output_and_status(self):
        result = runner.run(self.home, self.recipe())
        self.assertEqual(result["status"], "passed", result)
        self.assertIn("OK", Path(result["log"]).read_text())
        self.assertEqual(runner.load_job(self.home, result["id"])["status"], "passed")

    def test_failure_stops_following_commands(self):
        recipe = self.recipe("raise SystemExit(7)")
        recipe["steps"][0]["commands"].append([sys.executable, "-c", "open('unexpected','w').close()"])
        result = runner.run(self.home, recipe)
        self.assertEqual(result["status"], "failed")
        self.assertEqual(result["steps"][0]["exit_code"], 7)
        self.assertFalse((self.home / "unexpected").exists())

    def test_missing_input_does_not_run(self):
        recipe = self.recipe("open('unexpected','w').close()")
        recipe["steps"][0]["inputs"] = [str(self.home / "missing")]
        self.assertEqual(runner.run(self.home, recipe)["status"], "failed")
        self.assertFalse((self.home / "unexpected").exists())

    def test_deadline_is_shared_across_commands(self):
        recipe = self.recipe("import time; time.sleep(.35)", timeout=.65)
        recipe["steps"][0]["commands"] *= 3
        began = time.monotonic()
        result = runner.run(self.home, recipe)
        self.assertEqual(result["status"], "timed_out")
        self.assertLess(time.monotonic() - began, 3)
        self.assertFalse((self.home / "jobs/active.lock").exists())

    def test_step_deadline_is_not_reset_for_each_command(self):
        recipe = self.recipe("import time; time.sleep(.35)")
        recipe["steps"][0]["timeout"] = .65
        recipe["steps"][0]["commands"] *= 3
        self.assertEqual(runner.run(self.home, recipe)["status"], "timed_out")

    def test_cancel_from_other_client(self):
        started, answer = [], []
        ready = threading.Event()
        def on_started(value):
            started.append(value["id"])
            ready.set()
        thread = threading.Thread(target=lambda: answer.append(runner.run(self.home, self.recipe("import time; time.sleep(20)"), on_started)))
        thread.start()
        self.assertTrue(ready.wait(5))
        self.assertEqual(runner.cancel(self.home, started[0])["status"], "cancel_requested")
        thread.join(5)
        self.assertFalse(thread.is_alive())
        self.assertEqual(answer[0]["status"], "cancelled")

    def test_existing_lock_is_not_removed(self):
        (self.home / "jobs").mkdir()
        lock = self.home / "jobs/active.lock"
        lock.write_text("existing")
        with self.assertRaises(RuntimeError):
            runner.run(self.home, self.recipe())
        self.assertEqual(lock.read_text(), "existing")

    def test_arguments_are_not_shell_code(self):
        recipe = self.recipe("import sys; print(sys.argv[1])")
        recipe["steps"][0]["commands"][0].append("a b & $(do-not-run)")
        result = runner.run(self.home, recipe)
        self.assertEqual(result["status"], "passed")
        self.assertIn("a b & $(do-not-run)", Path(result["log"]).read_text())

    def test_unknown_external_and_retry_recipes_are_blocked(self):
        for kind in ("unknown", "external_metered", None):
            recipe = self.recipe()
            recipe["steps"][0]["cost_class"] = kind
            with self.assertRaises(ValueError):
                runner.run(self.home, recipe)
        recipe = self.recipe()
        recipe["steps"][0]["retries"] = 1
        with self.assertRaises(ValueError):
            runner.run(self.home, recipe)
        self.assertFalse((self.home / "jobs").exists())

    def test_limits_and_invalid_job_ids_are_blocked(self):
        for timeout in (float("inf"), float("nan"), 0, 1201):
            with self.assertRaises(ValueError):
                runner.run(self.home, self.recipe(timeout=timeout))
        recipe = self.recipe()
        recipe["steps"] *= 13
        with self.assertRaises(ValueError):
            runner.run(self.home, recipe)
        with self.assertRaises(ValueError):
            runner.cancel(self.home, "../../unexpected")

    def test_summary_output_is_bounded(self):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            hub.emit([{"id": "x", "message": "x" * 2000}] * 20)
        self.assertLessEqual(len(output.getvalue().encode()), 4096)
        json.loads(output.getvalue())

    def test_invalid_services_are_blocked(self):
        recipe = self.recipe()
        recipe["steps"][0]["detached"] = True
        with self.assertRaises(ValueError):
            runner.run(self.home, recipe)

    def test_status_write_survives_briefly_locked_file(self):
        # Windows-Fall: Ein Leser hält job.json offen, os.replace scheitert kurz.
        calls = []
        real = os.replace
        def flaky(source, target):
            calls.append(1)
            if len(calls) <= 3:
                raise PermissionError("gesperrt")
            real(source, target)
        target = self.home / "state.json"
        with unittest.mock.patch.object(runner.os, "replace", flaky):
            runner.write_json(target, {"status": "running"})
        self.assertEqual(runner.read_json(target)["status"], "running")
        self.assertEqual(len(calls), 4)
        self.assertEqual([p.name for p in self.home.glob("*.tmp")], [])

    def test_status_write_gives_up_visibly(self):
        def always(source, target):
            raise PermissionError("dauerhaft gesperrt")
        began = time.monotonic()
        with unittest.mock.patch.object(runner.os, "replace", always):
            with self.assertRaises(PermissionError):
                runner.write_json(self.home / "state.json", {"status": "x"})
        self.assertLess(time.monotonic() - began, 5)
        self.assertEqual(list(self.home.glob("*.tmp")), [])

    def test_reader_retries_half_written_file(self):
        target = self.home / "state.json"
        target.write_text("{", encoding="utf-8")
        timer = threading.Timer(.15, lambda: target.write_text('{"status": "passed"}', encoding="utf-8"))
        timer.start()
        try:
            self.assertEqual(runner.read_json(target)["status"], "passed")
        finally:
            timer.cancel()

    def test_concurrent_reader_while_job_runs(self):
        started, answer, errors = [], [], []
        ready = threading.Event()
        def on_started(value):
            started.append(value["id"])
            ready.set()
        recipe = self.recipe("import time; time.sleep(.6)")
        recipe["steps"][0]["commands"] *= 2
        thread = threading.Thread(target=lambda: answer.append(runner.run(self.home, recipe, on_started)))
        thread.start()
        self.assertTrue(ready.wait(5))
        while thread.is_alive():
            try:
                runner.load_job(self.home, started[0])
            except Exception as error:  # pragma: no cover - Fehlerfall sichtbar machen
                errors.append(repr(error))
        thread.join(5)
        self.assertEqual(errors, [])
        self.assertEqual(answer[0]["status"], "passed")

    def spawn_tree(self):
        # Elternprozess und Enkel bleiben ohne Verwaltung lange aktiv.
        child = "import time; time.sleep(60)"
        return ("import subprocess,sys,time; from pathlib import Path; "
                f"p=subprocess.Popen([sys.executable,'-c',{child!r}]); "
                "Path('child.pid').write_text(str(p.pid)); time.sleep(60)")

    def wait_pid(self, name="child.pid"):
        path = self.home / name
        deadline = time.monotonic() + 8
        while time.monotonic() < deadline:
            if path.exists() and path.read_text():
                return int(path.read_text())
            time.sleep(.05)
        self.fail("Kindprozess wurde nicht gestartet")

    def assert_stopped(self, pid):
        for _ in range(60):
            if not process_alive(pid):
                return
            time.sleep(.05)
        self.fail(f"Eigener Kindprozess {pid} läuft weiter")

    def test_timeout_kills_grandchild_and_preserves_foreign_process(self):
        foreign = subprocess.Popen([sys.executable, "-c", "import time; time.sleep(60)"])
        try:
            result = runner.run(self.home, self.recipe(self.spawn_tree(), timeout=2))
            pid = self.wait_pid()
            self.assertEqual(result["status"], "timed_out")
            self.assert_stopped(pid)
            self.assertIsNone(foreign.poll())
        finally:
            foreign.kill()
            foreign.wait()

    @unittest.skipUnless(os.name == "nt", "Windows Job-Object-Crashschutz")
    def test_runner_crash_kills_own_tree(self):
        recipe_file = self.home / "recipe.json"
        recipe_file.write_text(json.dumps(self.recipe(self.spawn_tree(), timeout=60)), encoding="utf-8")
        program = "import json,sys; from pathlib import Path; import runner; runner.run(Path(sys.argv[1]),json.loads(Path(sys.argv[2]).read_text(encoding='utf-8')))"
        process = subprocess.Popen([sys.executable, "-c", program, str(self.home), str(recipe_file)], cwd=Path(__file__).parent)
        try:
            pid = self.wait_pid()
            process.kill()
            process.wait(5)
            self.assert_stopped(pid)
        finally:
            if process.poll() is None:
                process.kill()
                process.wait()


if __name__ == "__main__":
    unittest.main()

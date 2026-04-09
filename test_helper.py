"""
Shared test helper for Flutter projects.
Provides logging, emulator management, Flutter test runner, and result parsing.

Used by project-level run_tests.py scripts.
"""

import os
import re
import json
import time
import subprocess
from urllib.request import urlopen, Request
from urllib.parse import urlencode
from urllib.error import URLError, HTTPError


# ─── Config ──────────────────────────────────────────────────────────────────
ANDROID_HOME = os.environ.get("ANDROID_HOME", os.path.expanduser("~/Library/Android/sdk"))
EMULATOR = os.path.join(ANDROID_HOME, "emulator", "emulator")
ADB = os.path.join(ANDROID_HOME, "platform-tools", "adb")
AVDMANAGER = os.path.join(ANDROID_HOME, "cmdline-tools", "latest", "bin", "avdmanager")
SDKMANAGER = os.path.join(ANDROID_HOME, "cmdline-tools", "latest", "bin", "sdkmanager")

NOTIFY_URL = "" # Điền Telegram API URL vào đây nếu cần dùng test_helper sau này
BOOT_TIMEOUT = 300

# ─── Colors ──────────────────────────────────────────────────────────────────
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
NC = "\033[0m"


# ─── Logger ──────────────────────────────────────────────────────────────────
class TestLogger:
    """Logs to both console and a file."""

    def __init__(self, log_path):
        self.log_path = log_path
        with open(self.log_path, "w", encoding="utf-8") as f:
            f.write(f"=== Test run started at {time.strftime('%Y-%m-%d %H:%M:%S')} ===\n\n")

    def _write(self, message):
        with open(self.log_path, "a", encoding="utf-8") as f:
            clean = re.sub(r"\033\[[0-9;]*m", "", message)
            f.write(clean + "\n")

    def log(self, msg):
        line = f"{GREEN}[TEST]{NC} {msg}"
        print(line)
        self._write(f"[TEST] {msg}")

    def warn(self, msg):
        line = f"{YELLOW}[WARN]{NC} {msg}"
        print(line)
        self._write(f"[WARN] {msg}")

    def error(self, msg):
        line = f"{RED}[FAIL]{NC} {msg}"
        print(line)
        self._write(f"[FAIL] {msg}")

    def output(self, msg):
        """Log raw command output."""
        print(msg, end="")
        self._write(msg.rstrip("\n"))


# ─── Command Helpers ─────────────────────────────────────────────────────────

def run_cmd(cmd, logger=None, timeout=None):
    """Run a command, stream output to logger, return (exit_code, output_str)."""
    proc = subprocess.Popen(
        cmd, shell=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, bufsize=1,
    )
    output_lines = []
    try:
        for line in proc.stdout:
            output_lines.append(line)
            if logger:
                logger.output(line)
            else:
                print(line, end="")
        proc.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait()
    return proc.returncode, "".join(output_lines)


def run_cmd_silent(cmd, timeout=30):
    """Run a command silently, return (returncode, stdout)."""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        return result.returncode, result.stdout.strip()
    except subprocess.TimeoutExpired:
        return -1, ""


# ─── Flutter Test Runner ─────────────────────────────────────────────────────

def run_flutter_tests(test_path, logger, timeout=600, extra_args="", device_id=None):
    """
    Run `flutter test` with machine-readable JSON output, parse results.
    Returns (exit_code, results_dict).
    results_dict has keys: tests, passed, failed, skipped, errors, failed_tests.
    """
    device_flag = f"-d {device_id}" if device_id else ""
    cmd = f"flutter test --machine {device_flag} {extra_args} {test_path}".strip()
    logger.log(f"Running: {cmd}")

    proc = subprocess.Popen(
        cmd, shell=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True, bufsize=1,
    )

    json_lines = []
    raw_output = []
    try:
        for line in proc.stdout:
            raw_output.append(line)
            line_stripped = line.strip()
            if line_stripped.startswith("{"):
                json_lines.append(line_stripped)
            else:
                logger.output(line)
        stderr_out = proc.stderr.read()
        if stderr_out.strip():
            logger.output(stderr_out)
        proc.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait()
        logger.error(f"Tests timed out after {timeout}s")
        return -1, None

    results = parse_flutter_json_results(json_lines, logger)
    return proc.returncode, results


def parse_flutter_json_results(json_lines, logger):
    """
    Parse flutter test --machine JSON events.
    Returns dict: tests, passed, failed, skipped, errors, failed_tests.
    """
    test_map = {}  # id -> {name, suite}
    total = 0
    passed = 0
    failed = 0
    skipped = 0
    errors = 0
    failed_tests = []

    for raw in json_lines:
        try:
            event = json.loads(raw)
        except json.JSONDecodeError:
            continue

        etype = event.get("type")

        if etype == "testStart":
            t = event.get("test", {})
            tid = t.get("id")
            name = t.get("name", "unknown")
            # Skip loading/suite entries (they have groupIDs == [] in some versions)
            if tid is not None:
                test_map[tid] = {"name": name}

        elif etype == "testDone":
            tid = event.get("testID")
            hidden = event.get("hidden", False)
            skipped_flag = event.get("skipped", False)
            result = event.get("result", "")

            if hidden:
                continue

            total += 1
            if skipped_flag:
                skipped += 1
            elif result == "success":
                passed += 1
            elif result == "failure" or result == "error":
                failed += 1
                info = test_map.get(tid, {})
                failed_tests.append(info.get("name", f"test#{tid}"))

        elif etype == "error":
            tid = event.get("testID")
            msg = event.get("error", "")
            stack = event.get("stackTrace", "")
            info = test_map.get(tid, {})
            test_name = info.get("name", f"test#{tid}")
            logger.error(f"  ERROR in {test_name}: {msg}")
            if stack:
                # Log first 5 lines of stack trace
                for stack_line in stack.split("\n")[:5]:
                    logger.output(f"    {stack_line}\n")
            errors += 1

        elif etype == "done":
            # Final event
            if event.get("success") is False and failed == 0:
                # Something else went wrong
                errors += 1

    return {
        "tests": total,
        "passed": passed,
        "failed": failed,
        "skipped": skipped,
        "errors": errors,
        "failed_tests": failed_tests,
    }


def format_results(results):
    """Format results dict to a summary string."""
    if results is None:
        return "NO RESULTS (test runner error)"
    parts = [
        f"total={results['tests']}",
        f"passed={results['passed']}",
        f"failed={results['failed']}",
        f"skipped={results['skipped']}",
    ]
    if results.get("errors"):
        parts.append(f"errors={results['errors']}")
    return ", ".join(parts)


# ─── Notification ────────────────────────────────────────────────────────────

def send_notification(message, logger=None):
    """Send notification to Bitrix group."""
    log = logger.log if logger else print
    warn = logger.warn if logger else print

    try:
        query_string = urlencode({"message": message, "dialog_id": "chat1898"})
        url = f"{NOTIFY_URL}?{query_string}"
        req = Request(url)
        with urlopen(req, timeout=15) as response:
            if 200 <= response.status < 300:
                log(f"Notification sent (HTTP {response.status}).")
            else:
                warn(f"Notification failed (HTTP {response.status}).")
    except HTTPError as e:
        warn(f"Notification failed (HTTP {e.code}).")
    except (URLError, Exception) as e:
        warn(f"Notification error: {e}")


# ─── AVD Management ─────────────────────────────────────────────────────────

def list_avds():
    """Return list of existing AVD names."""
    _, output = run_cmd_silent(f'"{EMULATOR}" -list-avds')
    return [line.strip() for line in output.splitlines() if line.strip()]


def ensure_avd(avd_name, avd_device, avd_package, logger=None):
    """Create AVD if it doesn't exist. Downloads system image if needed."""
    log = logger.log if logger else print
    error = logger.error if logger else print

    if avd_name in list_avds():
        log(f"AVD '{avd_name}' already exists.")
        return True

    log(f"AVD '{avd_name}' not found — creating it...")

    image_dir = os.path.join(ANDROID_HOME, avd_package.replace(";", os.sep))
    if not os.path.isdir(image_dir):
        log(f"Downloading system image: {avd_package} ...")
        code, _ = run_cmd(f'yes | "{SDKMANAGER}" "{avd_package}"', logger=logger)
        if not os.path.isdir(image_dir):
            error(f"Failed to download system image '{avd_package}'.")
            return False

    cmd = (
        f'echo "no" | "{AVDMANAGER}" create avd'
        f' --name "{avd_name}"'
        f' --package "{avd_package}"'
        f' --device "{avd_device}"'
        f' --force'
    )
    code, _ = run_cmd(cmd, logger=logger)
    if code != 0:
        error(f"Failed to create AVD '{avd_name}'.")
        return False

    log(f"AVD '{avd_name}' created (device={avd_device}, image={avd_package}).")
    return True


def start_emulator(avd_name, logger=None, headless=True):
    """Start emulator if not already running. Returns (ready, started_by_us)."""
    log = logger.log if logger else print
    warn = logger.warn if logger else print
    error = logger.error if logger else print

    _, devices_output = run_cmd_silent(f'"{ADB}" devices')
    if "emulator-5554\tdevice" in devices_output:
        warn("Emulator already running — reusing it.")
        return True, False

    emu_args = [EMULATOR, "-avd", avd_name, "-no-audio", "-no-boot-anim",
                "-gpu", "swiftshader_indirect", "-no-snapshot-load"]
    if headless:
        emu_args += ["-no-window"]

    log(f"Booting emulator ({'headless' if headless else 'with window'})...")
    subprocess.Popen(emu_args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    log(f"Waiting for emulator to boot (timeout: {BOOT_TIMEOUT}s)...")
    start_time = time.time()
    while time.time() - start_time < BOOT_TIMEOUT:
        _, boot = run_cmd_silent(f'"{ADB}" -s emulator-5554 shell getprop sys.boot_completed')
        if boot.strip() == "1":
            elapsed = int(time.time() - start_time)
            log(f"Emulator booted in {elapsed}s.")
            run_cmd_silent(f'"{ADB}" -s emulator-5554 shell input keyevent 82')
            time.sleep(2)
            return True, True
        time.sleep(3)

    error(f"Emulator failed to boot within {BOOT_TIMEOUT}s.")
    return False, True


def stop_emulator(logger=None):
    """Stop the emulator."""
    log = logger.log if logger else print
    log("Shutting down emulator...")
    run_cmd_silent(f'"{ADB}" -s emulator-5554 emu kill')

    for _ in range(30):
        _, devices_output = run_cmd_silent(f'"{ADB}" devices')
        if "emulator-5554" not in devices_output:
            break
        time.sleep(1)
    log("Emulator stopped.")


# ─── Gitignore ───────────────────────────────────────────────────────────────

def ensure_gitignore(entry, project_dir=None):
    """Add entry to .gitignore if not already present."""
    gitignore_path = os.path.join(project_dir or ".", ".gitignore")

    lines = []
    if os.path.exists(gitignore_path):
        with open(gitignore_path, "r", encoding="utf-8") as f:
            lines = f.readlines()

    stripped = [line.strip() for line in lines]
    if entry in stripped:
        return

    with open(gitignore_path, "a", encoding="utf-8") as f:
        if lines and not lines[-1].endswith("\n"):
            f.write("\n")
        f.write(entry + "\n")

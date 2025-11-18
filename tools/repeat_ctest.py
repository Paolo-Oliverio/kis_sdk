#!/usr/bin/env python3
"""
repeat_ctest.py

Run ctest repeatedly (or a filtered subset) to reproduce flaky tests.

Usage (Windows cmd):
  py tools\repeat_ctest.py --repeat 100 --regex "High steal contention"

By default it runs: ctest --preset debugTest --output-on-failure
You can override the ctest command with --ctest-cmd.
"""
import argparse
import shlex
import subprocess
import sys
import time


def run_once(ctest_cmd, regex):
    cmd = ctest_cmd
    if regex:
        cmd = cmd + " -R " + shlex.quote(regex)
    print(f"Running: {cmd}")
    start = time.time()
    # Use shell on Windows to allow preset/powershell quoting; subprocess.run will handle exit codes
    result = subprocess.run(cmd, shell=True)
    elapsed = time.time() - start
    return result.returncode, elapsed


def main():
    parser = argparse.ArgumentParser(description="Repeat ctest runs to reproduce flaky tests")
    parser.add_argument("--repeat", "-n", type=int, default=10, help="Number of repetitions (default: 10)")
    parser.add_argument("--regex", "-R", type=str, default="", help="Regex to pass to ctest -R to filter tests")
    parser.add_argument("--ctest-cmd", type=str, default="ctest --preset debugTest --output-on-failure", help="ctest command to run (default uses debugTest preset)")
    parser.add_argument("--stop-on-fail", action="store_true", help="Stop on first non-zero exit status")
    parser.add_argument("--sleep", type=float, default=0.1, help="Seconds to sleep between runs (default: 0.1)")

    args = parser.parse_args()

    failures = 0
    for i in range(1, args.repeat + 1):
        print(f"\n=== Run {i}/{args.repeat} ===")
        code, elapsed = run_once(args.ctest_cmd, args.regex)
        print(f"Exit code: {code} (elapsed {elapsed:.2f}s)")
        if code != 0:
            failures += 1
            print(f"*** Run {i} FAILED (exit {code})")
            if args.stop_on_fail:
                print("Stopping early due to --stop-on-fail")
                break
        time.sleep(args.sleep)

    print(f"\nFinished {i} runs: {failures} failures, {i - failures} successes")
    sys.exit(1 if failures else 0)


if __name__ == '__main__':
    main()

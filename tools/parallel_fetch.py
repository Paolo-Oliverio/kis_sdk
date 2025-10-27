#!/usr/bin/env python3
"""
Parallel Dependency Fetch Script for KIS SDK

This script fetches git repositories and downloads archives in parallel,
dramatically speeding up CMake's FetchContent operations.

Usage:
    python parallel_fetch.py <data_file.json> [--mode=fetch|clone]

Modes:
    fetch - Fetch third-party dependencies (FetchContent)
    clone - Clone first-party packages (git clone)
"""

import sys
import json
import subprocess
import os
import stat
import shutil
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Dict, List, Tuple
import time
import urllib.request
import hashlib


def remove_readonly(func, path, _):
    """Error handler for Windows readonly files."""
    os.chmod(path, stat.S_IWRITE)
    func(path)


class ParallelFetcher:
    def __init__(self, data_file: str, mode: str = "fetch"):
        self.data_file = Path(data_file)
        self.mode = mode
        self.load_config()
        self.success_count = 0
        self.failure_count = 0
        self.failures: List[Tuple[str, str]] = []

    def load_config(self):
        """Load configuration from JSON file."""
        with open(self.data_file, 'r', encoding='utf-8') as f:
            self.config = json.load(f)

        self.worker_count = self.config.get('worker_count', 4)

        if self.mode == "fetch":
            self.dependencies = self.config.get('dependencies', [])
        else:  # clone mode
            self.packages = self.config.get('packages', [])
            self.git_executable = self.config.get('git_executable', 'git')

    def fetch_git_dependency(self, dep: Dict) -> Tuple[bool, str, str]:
        """Fetch a single git-based dependency."""
        name = dep['name']
        git_repo = dep.get('git_repository', '')
        git_tag = dep.get('git_tag', 'master')
        source_dir = Path(dep['source_dir'])

        try:
            # Check if already exists
            if source_dir.exists() and (source_dir / '.git').exists():
                return True, name, f"Already exists: {source_dir}"

            # Create parent directory
            source_dir.parent.mkdir(parents=True, exist_ok=True)

            # Clone with shallow depth
            start_time = time.time()
            result = subprocess.run(
                ['git', 'clone', '--depth', '1', '--branch', git_tag,
                 '--recursive', '--shallow-submodules', git_repo, str(source_dir)],
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout per dependency
            )
            elapsed = time.time() - start_time

            if result.returncode != 0:
                return False, name, f"Git clone failed: {result.stderr}"

            return True, name, f"[OK] {name} ({elapsed:.1f}s)"

        except subprocess.TimeoutExpired:
            return False, name, f"Timeout after 5 minutes"
        except Exception as e:
            return False, name, f"Exception: {str(e)}"

    def fetch_url_dependency(self, dep: Dict) -> Tuple[bool, str, str]:
        """Fetch a single URL-based dependency."""
        name = dep['name']
        url = dep.get('url', '')
        url_hash = dep.get('url_hash', '')
        source_dir = Path(dep['source_dir'])

        try:
            # Check if already exists
            if source_dir.exists():
                return True, name, f"Already exists: {source_dir}"

            # Create temp download location
            temp_dir = source_dir.parent / f"_temp_{name}"
            temp_dir.mkdir(parents=True, exist_ok=True)

            # Download file
            filename = url.split('/')[-1]
            download_path = temp_dir / filename

            start_time = time.time()
            urllib.request.urlretrieve(url, str(download_path))
            elapsed = time.time() - start_time

            # Verify hash if provided
            if url_hash:
                hash_type, expected_hash = url_hash.split('=', 1)
                actual_hash = self.compute_hash(
                    download_path, hash_type.lower())

                if actual_hash.lower() != expected_hash.lower():
                    shutil.rmtree(temp_dir, onerror=remove_readonly)
                    return False, name, f"Hash mismatch: expected {expected_hash}, got {actual_hash}"

            # Extract archive
            shutil.unpack_archive(str(download_path), str(source_dir))
            shutil.rmtree(temp_dir, onerror=remove_readonly)

            return True, name, f"[OK] {name} ({elapsed:.1f}s)"

        except Exception as e:
            if temp_dir.exists():
                shutil.rmtree(temp_dir, onerror=remove_readonly)
            return False, name, f"Exception: {str(e)}"

    def clone_first_party_package(self, pkg: Dict) -> Tuple[bool, str, str]:
        """Clone a single first-party package."""
        name = pkg['name']
        url = pkg['url']
        tag = pkg['tag']
        temp_dir_str = pkg.get('temp_dir', '')
        final_dir_str = pkg.get('final_dir', '')
        temp_dir = Path(temp_dir_str) if temp_dir_str else None
        final_dir = Path(final_dir_str) if final_dir_str else None

        if not temp_dir or not final_dir:
            return False, name, f"Missing temp_dir or final_dir in package config"

        try:
            # Check if already exists
            if final_dir.exists() and (final_dir / '.git').exists():
                return True, name, f"Already exists: {final_dir}"

            # Clean up any leftover temp directory from previous failed attempt
            if temp_dir.exists():
                try:
                    shutil.rmtree(temp_dir, onerror=remove_readonly)
                except Exception as cleanup_err:
                    return False, name, f"Failed to cleanup temp dir: {cleanup_err}"

            # Create parent directory
            temp_dir.parent.mkdir(parents=True, exist_ok=True)

            # Clone to temp location
            start_time = time.time()
            result = subprocess.run(
                [self.git_executable, 'clone', '--depth', '1', '--branch', tag,
                 '--recursive', url, str(temp_dir)],
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )
            elapsed = time.time() - start_time

            if result.returncode != 0:
                if temp_dir.exists():
                    shutil.rmtree(temp_dir, onerror=remove_readonly)
                return False, name, f"Git clone failed: {result.stderr}"

            # Move to final location
            # Only remove final_dir if it's an actual git repository (not just an empty parent)
            if final_dir.exists() and (final_dir / '.git').exists():
                shutil.rmtree(final_dir, onerror=remove_readonly)

            final_dir.parent.mkdir(parents=True, exist_ok=True)

            # Remove empty final_dir if it exists (from previous failed attempt)
            if final_dir.exists():
                try:
                    os.rmdir(str(final_dir))
                except Exception:
                    pass  # Will fail on rename if directory still exists

            # Atomic rename from temp to final location
            # On Windows, retry a few times if we get permission errors
            max_retries = 3
            for attempt in range(max_retries):
                try:
                    os.rename(str(temp_dir), str(final_dir))
                    break
                except PermissionError as e:
                    if attempt < max_retries - 1:
                        # Wait a bit for Windows to release file handles
                        time.sleep(0.5)
                    else:
                        # Last attempt failed, clean up and report error
                        if temp_dir.exists():
                            shutil.rmtree(temp_dir, onerror=remove_readonly)
                        return False, name, f"Permission error after {max_retries} attempts: {e}"
                except Exception as e:
                    # Other errors, don't retry
                    if temp_dir.exists():
                        shutil.rmtree(temp_dir, onerror=remove_readonly)
                    return False, name, f"Failed to move to final location: {e}"

            return True, name, f"[OK] {name} ({elapsed:.1f}s)"

        except subprocess.TimeoutExpired:
            if temp_dir.exists():
                shutil.rmtree(temp_dir, onerror=remove_readonly)
            return False, name, f"Timeout after 5 minutes"
        except Exception as e:
            if temp_dir.exists():
                shutil.rmtree(temp_dir, onerror=remove_readonly)
            return False, name, f"Exception: {str(e)}"

    def compute_hash(self, file_path: Path, hash_type: str) -> str:
        """Compute hash of a file."""
        hash_obj = hashlib.new(hash_type)
        with open(file_path, 'rb') as f:
            for chunk in iter(lambda: f.read(8192), b''):
                hash_obj.update(chunk)
        return hash_obj.hexdigest()

    def run_fetch(self):
        """Run parallel fetch for third-party dependencies."""
        if not self.dependencies:
            print("No dependencies to fetch")
            return True

        print(
            f"Starting parallel fetch of {len(self.dependencies)} dependencies with {self.worker_count} workers...")

        start_time = time.time()

        with ThreadPoolExecutor(max_workers=self.worker_count) as executor:
            futures = {}

            for dep in self.dependencies:
                dep_type = dep.get('type', 'git')
                if dep_type == 'git':
                    future = executor.submit(self.fetch_git_dependency, dep)
                else:  # url
                    future = executor.submit(self.fetch_url_dependency, dep)
                futures[future] = dep['name']

            for future in as_completed(futures):
                success, name, message = future.result()
                if success:
                    self.success_count += 1
                    print(message)
                else:
                    self.failure_count += 1
                    self.failures.append((name, message))
                    print(f"[FAIL] {name}: {message}")

        elapsed = time.time() - start_time

        print(f"\nParallel fetch completed in {elapsed:.1f}s")
        print(f"Success: {self.success_count}, Failed: {self.failure_count}")

        if self.failures:
            print("\nFailed dependencies:")
            for name, error in self.failures:
                print(f"  - {name}: {error}")
            return False

        return True

    def run_clone(self):
        """Run parallel clone for first-party packages."""
        if not self.packages:
            print("No packages to clone")
            return True

        print(
            f"Starting parallel clone of {len(self.packages)} packages with {self.worker_count} workers...")

        start_time = time.time()

        with ThreadPoolExecutor(max_workers=self.worker_count) as executor:
            futures = {}

            for pkg in self.packages:
                future = executor.submit(self.clone_first_party_package, pkg)
                futures[future] = pkg['name']

            for future in as_completed(futures):
                success, name, message = future.result()
                if success:
                    self.success_count += 1
                    print(message)
                else:
                    self.failure_count += 1
                    self.failures.append((name, message))
                    print(f"[FAIL] {name}: {message}")

        elapsed = time.time() - start_time

        print(f"\nParallel clone completed in {elapsed:.1f}s")
        print(f"Success: {self.success_count}, Failed: {self.failure_count}")

        if self.failures:
            print("\nFailed packages:")
            for name, error in self.failures:
                print(f"  - {name}: {error}")
            return False

        return True

    def run(self):
        """Execute parallel operations."""
        try:
            if self.mode == "fetch":
                return self.run_fetch()
            else:  # clone
                return self.run_clone()
        except KeyboardInterrupt:
            print("\n\nInterrupted by user")
            return False
        except Exception as e:
            print(f"\n\nFatal error: {e}")
            import traceback
            traceback.print_exc()
            return False


def main():
    if len(sys.argv) < 2:
        print("Usage: parallel_fetch.py <data_file.json> [--mode=fetch|clone]")
        return 1

    data_file = sys.argv[1]
    mode = "fetch"

    # Parse optional mode argument
    for arg in sys.argv[2:]:
        if arg.startswith("--mode="):
            mode = arg.split('=', 1)[1]

    if not os.path.exists(data_file):
        print(f"Error: Data file not found: {data_file}")
        return 1

    fetcher = ParallelFetcher(data_file, mode)
    success = fetcher.run()

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())

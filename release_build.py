#!/usr/bin/env python3
"""
release_build.py
-----------------
Utility script that:
1. Creates a GitHub prerelease first
2. Builds and uploads Flutter artifacts concurrently
3. Marks the release as latest when complete
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import threading
from pathlib import Path
from typing import List

import requests

PROJECT_ROOT = Path(__file__).resolve().parent
PUBSPEC_PATH = PROJECT_ROOT / "pubspec.yaml"

# ---------------------------------------------------------------------------
# Util helpers
# ---------------------------------------------------------------------------

def run(cmd: List[str], **kwargs):
    """Run a shell command and exit on failure."""
    print("$", " ".join(cmd))
    
    # Use shell=True on Windows to access the full PATH
    if os.name == 'nt':  # Windows
        kwargs.setdefault('shell', True)
    
    try:
        subprocess.check_call(cmd, **kwargs)
    except FileNotFoundError:
        print(f"ERROR: Command '{cmd[0]}' not found. Please ensure it's installed and in your PATH.")
        if cmd[0] == "flutter":
            print("Flutter installation guide: https://docs.flutter.dev/get-started/install")
            print("Make sure to restart your command prompt after installing Flutter.")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"Command failed with exit code {e.returncode}")
        sys.exit(e.returncode)

def extract_version() -> str:
    """Parse the version from pubspec.yaml (first `version:` line)."""
    pattern = re.compile(r"^version:\s*(.*)$")
    with PUBSPEC_PATH.open(encoding="utf-8") as fp:
        for line in fp:
            m = pattern.match(line.strip())
            if m:
                return m.group(1)
    raise RuntimeError("Unable to find version in pubspec.yaml")

def zip_dir(src: Path, dest_zip: Path):
    """Zip the contents of *src* directory into *dest_zip*."""
    print(f"Zipping {src} -> {dest_zip}")
    if dest_zip.exists():
        dest_zip.unlink()
    shutil.make_archive(dest_zip.with_suffix(""), "zip", src)

def check_flutter_installation():
    """Verify Flutter is installed and accessible."""
    try:
        result = subprocess.run(["flutter", "--version"], 
                              capture_output=True, text=True, shell=True, timeout=30)
        if result.returncode == 0:
            version_line = result.stdout.split('\n')[0] if result.stdout else "version unknown"
            print(f"Flutter found: {version_line}")
            return True
        else:
            print(f"Flutter command failed with return code {result.returncode}")
            if result.stderr:
                print(f"Error output: {result.stderr}")
    except subprocess.TimeoutExpired:
        print("Flutter command timed out")
    except FileNotFoundError:
        print("Flutter command not found in PATH")
    except Exception as e:
        print(f"Error checking Flutter: {e}")
    
    # Try to find flutter.bat or flutter.exe in common locations
    flutter_paths = [
        "flutter", "flutter.bat", "flutter.exe",
        r"C:\flutter\bin\flutter.bat", r"C:\flutter\bin\flutter.exe",
        r"C:\tools\flutter\bin\flutter.bat", r"C:\tools\flutter\bin\flutter.exe",
    ]
    
    for flutter_path in flutter_paths:
        try:
            result = subprocess.run([flutter_path, "--version"], 
                                  capture_output=True, text=True, timeout=30)
            if result.returncode == 0:
                version_line = result.stdout.split('\n')[0] if result.stdout else "version unknown"
                print(f"Flutter found at {flutter_path}: {version_line}")
                return True
        except (FileNotFoundError, subprocess.TimeoutExpired, Exception):
            continue
    
    print("ERROR: Flutter is not accessible from this Python environment.")
    return False

# ---------------------------------------------------------------------------
# Config helpers
# ---------------------------------------------------------------------------

def load_config_file(path: Path) -> dict:
    """Load configuration from JSON or simple KEY=VALUE file."""
    if not path or not path.exists():
        return {}
    if path.suffix.lower() == ".json":
        with path.open(encoding="utf-8") as f:
            return json.load(f)
    data: dict[str, str] = {}
    with path.open(encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                k, v = line.split("=", 1)
                data[k.strip()] = v.strip()
    return data

# ---------------------------------------------------------------------------
# GitHub helpers
# ---------------------------------------------------------------------------

github_api = "https://api.github.com"

def create_or_get_prerelease(token: str, repo: str, tag: str, name: str):
    """Create or get a GitHub release, initially marked as prerelease."""
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github+json",
    }

    # Check if release already exists
    r = requests.get(f"{github_api}/repos/{repo}/releases/tags/{tag}", headers=headers)
    if r.status_code == 200:
        release = r.json()
        print(f"Found existing release id={release['id']} for tag {tag}")
        return release
    elif r.status_code != 404:
        print("Error fetching existing release:", r.text)
        r.raise_for_status()

    payload = {
        "tag_name": tag,
        "name": name,
        "body": f"Release {name}",
        "draft": False,
        "prerelease": True,  # Initially create as prerelease
    }

    print(f"Creating prerelease {tag} in {repo}…")
    r = requests.post(f"{github_api}/repos/{repo}/releases", json=payload, headers=headers)
    r.raise_for_status()
    return r.json()

def update_release_to_latest(token: str, repo: str, release_id: int):
    """Update the release to mark it as latest (remove prerelease status)."""
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github+json",
    }

    payload = {
        "prerelease": False  # Mark as latest release
    }

    print(f"Updating release id={release_id} to mark as latest release...")
    r = requests.patch(f"{github_api}/repos/{repo}/releases/{release_id}", json=payload, headers=headers)
    
    if r.status_code == 200:
        print(f"✅ Release successfully updated to latest!")
        return r.json()
    else:
        print(f"❌ Failed to update release: {r.status_code} {r.text}")
        r.raise_for_status()

def upload_asset_thread(token: str, upload_url_template: str, file_path: Path, asset_name: str):
    """Upload a single asset in a background thread."""
    headers = {
        "Authorization": f"token {token}",
        "Content-Type": "application/octet-stream",
    }

    upload_url = upload_url_template.split("{", 1)[0]  # remove templating var
    params = {"name": file_path.name}
    
    print(f"[UPLOAD] Starting upload of {asset_name}...")
    try:
        with file_path.open("rb") as fp:
            resp = requests.post(upload_url, params=params, data=fp, headers=headers)
        if resp.status_code not in (200, 201):
            print(f"[UPLOAD] Failed to upload {asset_name}:", resp.text)
            resp.raise_for_status()
        else:
            print(f"[UPLOAD] ✅ Successfully uploaded {asset_name}")
    except Exception as e:
        print(f"[UPLOAD] ❌ Error uploading {asset_name}: {e}")
        raise

# ---------------------------------------------------------------------------
# Concurrent Build and Upload Pipeline
# ---------------------------------------------------------------------------

def run_concurrent_build_upload(token: str, repo: str, upload_url_template: str, version: str, existing_names: set):
    """Execute the concurrent build and upload pipeline."""
    
    # Prepare paths
    aab_path = PROJECT_ROOT / "build" / "app" / "outputs" / "bundle" / "release" / "app-release.aab"
    apk_path = PROJECT_ROOT / "build" / "app" / "outputs" / "flutter-apk" / "app-release.apk"
    web_dir = PROJECT_ROOT / "build" / "web"
    web_zip = PROJECT_ROOT / f"web-release-{version}.zip"
    
    # Run flutter pub get first
    run(["flutter", "pub", "get"])
    
    # Step 1: Build AAB
    print("\n=== BUILDING AAB ===")
    run(["flutter", "build", "appbundle", "--release"])
    
    # Step 2: Start uploading AAB while building APK
    upload_aab_thread = None
    if aab_path.name not in existing_names and aab_path.exists():
        upload_aab_thread = threading.Thread(
            target=upload_asset_thread,
            args=(token, upload_url_template, aab_path, "AAB"),
            name="UploadAAB"
        )
        upload_aab_thread.start()
    else:
        print(f"[SKIP] AAB already exists in release or file not found")
    
    # Step 3: Build APK while AAB uploads
    print("\n=== BUILDING APK (while uploading AAB) ===")
    run(["flutter", "build", "apk", "--release"])
    
    # Wait for AAB upload to complete before starting APK upload
    if upload_aab_thread:
        print("[SYNC] Waiting for AAB upload to complete...")
        upload_aab_thread.join()
    
    # Step 4: Start uploading APK while building Web
    upload_apk_thread = None
    if apk_path.name not in existing_names and apk_path.exists():
        upload_apk_thread = threading.Thread(
            target=upload_asset_thread,
            args=(token, upload_url_template, apk_path, "APK"),
            name="UploadAPK"
        )
        upload_apk_thread.start()
    else:
        print(f"[SKIP] APK already exists in release or file not found")
    
    # Step 5: Build Web while APK uploads
    print("\n=== BUILDING WEB (while uploading APK) ===")
    run(["flutter", "build", "web", "--release"])
    
    # Wait for APK upload to complete
    if upload_apk_thread:
        print("[SYNC] Waiting for APK upload to complete...")
        upload_apk_thread.join()
    
    # Step 6: Zip and upload Web
    print("\n=== PREPARING AND UPLOADING WEB ===")
    if web_dir.exists():
        zip_dir(web_dir, web_zip)
        
        if web_zip.name not in existing_names:
            upload_asset_thread(token, upload_url_template, web_zip, "Web")
        else:
            print(f"[SKIP] Web zip already exists in release")
    else:
        print("[ERROR] Web build directory not found")

# ---------------------------------------------------------------------------
# Main entry
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Build Flutter release & GitHub upload with concurrent processing")
    parser.add_argument("--repo", default=os.getenv("GITHUB_REPOSITORY"), help="GitHub repository in owner/repo format")
    parser.add_argument("--token", default=os.getenv("GITHUB_TOKEN"), help="GitHub Personal Access Token with repo scope")
    parser.add_argument("--config", default=None, help="Path to config file (json or key=value).")
    args = parser.parse_args()

    # Resolve configuration precedence: CLI > env vars > config file
    config_path = Path(args.config) if args.config else (PROJECT_ROOT / "release_config.json")
    config = load_config_file(config_path) if config_path.exists() else {}

    repo = args.repo or os.getenv("GITHUB_REPOSITORY") or config.get("repo") or config.get("repository") or config.get("GITHUB_REPOSITORY")
    token = args.token or os.getenv("GITHUB_TOKEN") or config.get("token") or config.get("github_token") or config.get("GITHUB_TOKEN")

    if not repo or not token:
        print("ERROR: GitHub repo and token must be supplied via CLI flags, environment variables, or config file.")
        sys.exit(1)

    if not check_flutter_installation():
        sys.exit(1)

    version = extract_version()
    tag = f"v{version}"
    print(f"Version detected: {version}")

    try:
        # STEP 1: Create GitHub prerelease FIRST (before any builds)
        print("\n=== CREATING GITHUB PRERELEASE ===")
        release = create_or_get_prerelease(token, repo, tag=tag, name=version)
        release_id = release['id']
        
        existing_names = {asset["name"] for asset in release.get("assets", [])}
        upload_url_template = release["upload_url"]
        
        # STEP 2: Run concurrent build and upload pipeline
        print(f"\n=== STARTING CONCURRENT BUILD & UPLOAD PIPELINE ===")
        run_concurrent_build_upload(token, repo, upload_url_template, version, existing_names)

        # STEP 3: Mark release as latest when everything is complete
        print(f"\n=== FINALIZING RELEASE ===")
        update_release_to_latest(token, repo, release_id)

        print("\n🎉 Release completed successfully and marked as latest!")

    except Exception as e:
        print(f"\n❌ Error during release process: {e}")
        print("The release may have been created as prerelease but not finalized.")
        sys.exit(1)

if __name__ == "__main__":
    main()

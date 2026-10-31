#!/usr/bin/env python3
"""Fetches the pinned UVM library and checks that it is the one the lock names.

Usage:
    python3 tools/fetch_uvm.py              fetch it if missing, then check it
    python3 tools/fetch_uvm.py --check      check the copy that is there
    python3 tools/fetch_uvm.py --digest DIR print the digest of an extracted tree

third_party/uvm.lock names the release (version), where it comes from
(repository, tag and commit) and content_sha256, a digest of every file of
the release: its path below the top directory and the SHA-256 of its bytes.
The archive is fetched by commit, and the check is made on the extracted
files rather than on the archive, whose compressed bytes the host may change.
The library goes to third_party/uvm/<version>/, which is not committed.
"""

import argparse
import hashlib
import io
import json
import shutil
import sys
import tarfile
import tempfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOCK = ROOT / "third_party" / "uvm.lock"


def digest(tree: Path) -> tuple[str, int]:
    """The content digest of a tree and its number of files."""
    files = sorted(p for p in tree.rglob("*") if p.is_file())
    h = hashlib.sha256()
    for path in files:
        h.update(path.relative_to(tree).as_posix().encode() + b"\0")
        h.update(hashlib.sha256(path.read_bytes()).digest())
    return h.hexdigest(), len(files)


def extract(data: bytes, into: Path) -> Path:
    """Extract an archive with one top directory and return that directory."""
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as archive:
        for member in archive.getmembers():
            name = Path(member.name)
            if name.is_absolute() or ".." in name.parts or member.issym() or member.islnk():
                raise ValueError(f"unsafe archive member: {member.name}")
        archive.extractall(into)
    tops = [p for p in into.iterdir() if p.is_dir()]
    if len(tops) != 1:
        raise ValueError("the archive does not hold exactly one top directory")
    return tops[0]


def check(target: Path, lock: dict) -> str:
    """Why the copy at target is not the locked release, or "" if it is."""
    if not target.is_dir():
        return f"{target.relative_to(ROOT)} is missing"
    have, count = digest(target)
    if have != lock["content_sha256"] or count != lock["files"]:
        return f"{target.relative_to(ROOT)} differs from the lock ({count} files, {have})"
    return ""


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--check", action="store_true", help="only check the copy that is there")
    ap.add_argument("--digest", type=Path, help="print the digest of an extracted tree")
    args = ap.parse_args()
    if args.digest:
        value, count = digest(args.digest)
        print(json.dumps({"content_sha256": value, "files": count}))
        return 0
    lock = json.loads(LOCK.read_text(encoding="utf-8"))
    target = ROOT / "third_party" / "uvm" / lock["version"]
    if not args.check and not target.is_dir():
        with urllib.request.urlopen(lock["archive"], timeout=120) as response:
            data = response.read()
        with tempfile.TemporaryDirectory() as tmp:
            top = extract(data, Path(tmp))
            value, count = digest(top)
            if value != lock["content_sha256"] or count != lock["files"]:
                print(f"the fetched archive differs from the lock ({count} files, {value})",
                      file=sys.stderr)
                return 1
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(top), str(target))
    problem = check(target, lock)
    if problem:
        print(problem, file=sys.stderr)
        return 1
    print(f"UVM {lock['version']} ({lock['commit'][:12]}) is in {target.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

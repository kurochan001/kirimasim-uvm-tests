"""What every runner of this suite shares about the UVM library.

The pinned release is named by third_party/uvm.lock and fetched into
third_party/uvm/<version>/ by tools/fetch_uvm.py. Each test is compiled with
the library's package (src/uvm_pkg.sv, with src/ on the include path) before
its own sources.

UVM_NO_DPI is defined unless the test sets :uvm_dpi: yes: the library's DPI
code for HDL backdoor access has implementations for three commercial
simulators only. Without DPI the library reads +UVM_TESTNAME itself, matches
names with globs instead of regular expressions and does not check component
names, so a test that depends on those needs :uvm_dpi: yes. :uvm_defines:
adds macros such as UVM_ENABLE_DEPRECATED_API.

A test observes results on lines that begin with "UT: " (see README.md,
"What is observed"); only those lines are compared with the expected output.
"""

import json
from pathlib import Path

import suite_results

ROOT = Path(__file__).resolve().parent.parent
LOCK = ROOT / "third_party" / "uvm.lock"
OBSERVED = "UT: "


def lock() -> dict:
    return json.loads(LOCK.read_text(encoding="utf-8"))


def library_dir() -> Path:
    """Where the pinned release is extracted."""
    return ROOT / "third_party" / "uvm" / lock()["version"]


def defines(test: Path) -> list[str]:
    fields = suite_results.header(test)
    names = [] if fields.get("uvm_dpi") == "yes" else ["UVM_NO_DPI"]
    return names + fields.get("uvm_defines", "").split()


def include_dirs() -> list[Path]:
    return [library_dir() / "src"]


def sources() -> list[Path]:
    return [library_dir() / "src" / "uvm_pkg.sv"]


def version_problem(test: Path) -> str:
    """Why the pinned library cannot run the test, or "" if it can."""
    want = suite_results.header(test).get("uvm")
    have = lock()["version"]
    if want != have:
        return f"the test asks for UVM {want}, the pinned library is {have}"
    if not (library_dir() / "src" / "uvm_pkg.sv").is_file():
        return "the UVM library is not fetched (run python3 tools/fetch_uvm.py)"
    return ""


def observed(stdout: str) -> str:
    """The lines of the output that the test prints for comparison."""
    return "".join(line + "\n" for line in stdout.splitlines() if line.startswith(OBSERVED))

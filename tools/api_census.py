#!/usr/bin/env python3
"""Counts, for each declaration that the pinned library marks with a clause of
the standard, the tests that use it, and checks coverage/api_census.json, the
list of the marked declarations that no test uses.

Usage:
    python3 tools/api_census.py check [-j N] [--json FILE]
    python3 tools/api_census.py update [-j N] [--json FILE]
    python3 tools/api_census.py summary [--lang en|ja]

The pinned library carries comments of the form `@uvm-ieee 1800.2-2020 auto
5.3.4.1` (or `manual`) before a declaration. The comment is the library's
claim, not the standard; a clause is confirmed against the standard before a
declaration is treated as a gap. The census reads the declaration after each
comment: a class, function, task, macro or typedef. A comment before anything
else, such as a variable, is counted as other and not followed further.

A test uses a function or task when slang resolves a call in the test's own
sources (the files under tests/) to that declaration or to a method that
overrides it, or when a method declared in those sources overrides it. A
macro, class or typedef is used when its name occurs in the code of the
test's own sources, with comments and string literals removed. The census
needs pyslang in the version of coverage/slang_frontend.json and elaborates
each test as tools/slang_elaborate.py does; a test that slang cannot elaborate
contributes only the calls that slang still resolves.

The record holds two lists. "unused" names the functions, tasks and macros
that no test uses and whose name occurs in no test's code. "name_only" names
the functions and tasks whose name occurs in some test although no call or
override resolves to them: a call through a derived class or a port, a use in
a test that slang cannot elaborate, or a different method of the same name.
check fails when either list differs from the current tests; update rewrites
them, and the change is reviewed before it is committed. --json also writes
the count of using tests for every declaration. See docs/requirements.md,
"API census", and its Japanese counterpart.
"""

import argparse
from collections import Counter
import concurrent.futures
import json
import os
from pathlib import Path
import re
import subprocess
import sys

import slang_elaborate
import suite_results

ROOT = Path(__file__).resolve().parent.parent
RECORD = Path("coverage") / "api_census.json"
ANNOTATION = re.compile(r"@uvm-ieee\s+1800\.2-2020\s+(auto|manual)\s+(\S+)")
NOT_CODE = re.compile(r'"(?:\\.|[^"\\\n])*"|//[^\n]*|/\*.*?\*/', re.S)
CLASS = re.compile(r"^\s*(?:virtual\s+)?class\s+(?:(?:static|automatic)\s+)?(\w+)")
ROUTINE = re.compile(
    r"^\s*(?:(?:extern|static|virtual|pure|protected|local|import|export)\s+)*"
    r"(function|task)\b(?P<rest>[^;(]*)")
MACRO = re.compile(r"^\s*`(?:define|ifndef)\s+(\w+)")
TYPEDEF = re.compile(r"^\s*typedef\b[^;]*?\b(\w+)\s*(?:\[[^\]]*\]\s*)*;")
KINDS = ("class", "function", "task", "macro", "typedef")
SOURCE_SUFFIXES = {".sv", ".svh", ".v", ".vh"}


class CensusError(ValueError):
    """The record does not match the library or the tests."""


def require(condition, message):
    if not condition:
        raise CensusError(message)


def library_dir(root):
    lock = json.loads((root / "third_party" / "uvm.lock").read_text(encoding="utf-8"))
    return root / "third_party" / "uvm" / lock["version"], lock["version"]


def parse_file(text, name):
    """The annotated declarations of one library file."""
    lines = text.split("\n")
    found, classes = [], []
    for number, line in enumerate(lines):
        code = line.split("//")[0]
        m = CLASS.match(code)
        if m:
            classes.append(m.group(1))
        elif re.match(r"^\s*endclass\b", code) and classes:
            classes.pop()
        a = ANNOTATION.search(line)
        if not a:
            continue
        # The declaration: the next line that is not a comment or blank, joined
        # with what follows it up to the end of its header.
        # A comment inside a declaration marks that declaration.
        if re.sub(r"/\*.*?\*/", "", line).split("//")[0].strip():
            k = number
        else:
            k = number + 1
            while k < len(lines) and (not lines[k].strip() or lines[k].strip().startswith("//")):
                k += 1
        head = " ".join(re.sub(r"/\*.*?\*/", "", l).split("//")[0] for l in lines[k:k + 6])
        entry = {"clause": a.group(2), "mode": a.group(1), "file": name, "line": k + 1}
        c, r, d, t = CLASS.match(head), ROUTINE.match(head), MACRO.match(head), None
        if not (c or r or d):
            # The comment may stand between "function" and the routine's name.
            before = number - 1
            while before >= 0 and (not lines[before].strip()
                                   or lines[before].strip().startswith("//")):
                before -= 1
            if before >= 0 and re.search(r"\b(function|task)\b[^;(]*$", lines[before].split("//")[0]):
                r = ROUTINE.match(lines[before].split("//")[0] + " " + head)
        if not (c or r or d) and re.match(r"^\s*typedef\b", head):
            # A typedef ends at the first semicolon outside braces.
            depth, text = 0, ""
            for ch in " ".join(re.sub(r"/\*.*?\*/", "", l).split("//")[0]
                               for l in lines[k:k + 120]):
                text += ch
                depth += (ch == "{") - (ch == "}")
                if ch == ";" and depth == 0:
                    break
            t = TYPEDEF.match(re.sub(r"\{.*\}", " ", text))
        if c:
            entry.update(kind="class", name=c.group(1), scope=None)
        elif r:
            words = re.findall(r"[\w:]+", re.sub(r"#\s*\(.*?\)|\[[^\]]*\]", " ", r.group("rest")))
            if not words:
                entry.update(kind="other", name=None, scope=None)
            else:
                scope, _, routine = words[-1].rpartition("::")
                entry.update(kind=r.group(1), name=routine,
                             scope=scope or (classes[-1] if classes else None))
        elif d:
            entry.update(kind="macro", name=d.group(1), scope=None)
        elif t:
            entry.update(kind="typedef", name=t.group(1), scope=classes[-1] if classes else None)
        else:
            entry.update(kind="other", name=None, scope=None)
        found.append(entry)
    return found


def declarations(root=None):
    """Every annotated declaration of the pinned library, in file order."""
    root = root or ROOT
    library, _ = library_dir(root)
    found = []
    for path in sorted((library / "src").rglob("*")):
        if path.suffix in SOURCE_SUFFIXES and path.is_file():
            text = path.read_text(encoding="utf-8", errors="replace")
            if "@uvm-ieee" in text:
                found.extend(parse_file(text, path.relative_to(library).as_posix()))
    return found


def key(entry):
    return f"{entry['scope']}::{entry['name']}" if entry["scope"] else entry["name"]


def own_code(test, root):
    """The code of the test's own sources, without comments and strings."""
    parts = []
    for path in suite_results.input_files(test):
        if (path.is_relative_to(root / "tests") and path.suffix in SOURCE_SUFFIXES
                and path.is_file()):
            parts.append(NOT_CODE.sub(" ", path.read_text(encoding="utf-8", errors="replace")))
    return "\n".join(parts)


def routine_key(path):
    """Class and name from a hierarchical path such as
    uvm_pkg::uvm_tlm_fifo#(int)::get, or None outside uvm_pkg."""
    depth, plain = 0, []
    for ch in path:
        if ch in "([":
            depth += 1
        elif ch in ")]":
            depth -= 1
        elif depth == 0 and ch != "#":
            plain.append(ch)
    parts = "".join(plain).split("::")
    if parts[0] != "uvm_pkg" or len(parts) < 2:
        return None
    return "::".join(parts[-2:]) if len(parts) > 2 else parts[1]


def resolved(test, options, root):
    """The library routines that the test's own sources call or override."""
    import pyslang
    ast = pyslang.ast
    driver = pyslang.driver.Driver()
    driver.addStandardArgs()
    line = " ".join(["slang", *slang_elaborate.command(test, options)])
    if not (driver.parseCommandLine(line) and driver.processOptions()
            and driver.parseAllSources()):
        return set()
    compilation = driver.createCompilation()
    compilation.getAllDiagnostics()
    manager = compilation.sourceManager
    tests_dir = (root / "tests").resolve()
    used, own_files = set(), {}

    def own(location):
        # slang gives a file name relative to the working directory.
        name = str(manager.getFileName(manager.getFullyExpandedLoc(location)))
        if name not in own_files:
            own_files[name] = bool(name) and Path(name).resolve().is_relative_to(tests_dir)
        return own_files[name]

    def credit(symbol):
        while symbol is not None:
            found = routine_key(symbol.hierarchicalPath)
            if found:
                used.add(found)
            symbol = symbol.override

    def visit(node):
        if isinstance(node, ast.CallExpression):
            if isinstance(node.subroutine, ast.SubroutineSymbol) and own(node.sourceRange.start):
                credit(node.subroutine)
        elif isinstance(node, ast.SubroutineSymbol) and own(node.location):
            credit(node.override)
        return True

    # Only the test's own code is walked: its packages, the declarations at
    # compilation-unit scope and the bodies of the top instances. Walking the
    # whole library for every test would take most of the time and find no
    # call site in the test's sources.
    for package in compilation.getPackages():
        if own(package.location):
            package.visit(visit)
    for unit in compilation.getCompilationUnits():
        for member in unit:
            if not isinstance(member, ast.PackageSymbol) and own(member.location):
                member.visit(visit)
    for instance in compilation.getRoot().topInstances:
        instance.body.visit(visit)
    return used


def one_test(name, options, root):
    """The routines that one test uses and the code of its own sources. slang
    runs in a process of its own for each test, as in tools/slang_elaborate.py:
    a long-lived process that elaborates many tests keeps their memory."""
    test = root / "tests" / (name + ".sv")
    r = subprocess.run([sys.executable, str(Path(__file__).resolve()), "resolve", str(root),
                        name, *options], capture_output=True, text=True, errors="replace",
                       timeout=900)
    try:
        calls = json.loads(r.stdout.strip().splitlines()[-1])
    except (ValueError, IndexError):   # a test that slang cannot handle counts by name only
        calls = []
        print(f"api_census: {name}: no result from slang: {r.stderr.strip()[-200:]}",
              file=sys.stderr)
    return name, calls, own_code(test, root)


def census(jobs, root=None):
    """For each declaration, the tests that use it and those that name it."""
    root = root or ROOT
    found = [d for d in declarations(root) if d["kind"] in KINDS]
    options = slang_elaborate.load(root)["options"]
    names = sorted(suite_results.test_id(t) for t in suite_results.find_tests(root))
    routines = {key(d) for d in found if d["kind"] in ("function", "task")}
    words = {d["name"] for d in found}
    pattern = re.compile(r"`?\b(?:" + "|".join(sorted(map(re.escape, words))) + r")\b")
    used = {key(d): 0 for d in found}
    named = {d["name"]: 0 for d in found}
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as pool:
        for _, calls, code in pool.map(lambda n: one_test(n, options, root), names):
            for call in calls:
                if call in routines:
                    used[call] += 1
            for word in set(pattern.findall(code)):
                macro = word.startswith("`")
                bare = word.lstrip("`")
                named[bare] = named.get(bare, 0) + 1
                for d in found:
                    if d["name"] == bare and d["kind"] not in ("function", "task") \
                            and (d["kind"] == "macro") == macro:
                        used[key(d)] += 1
    rows, seen = [], set()
    for d in found:
        if (d["kind"], key(d)) in seen:
            continue
        seen.add((d["kind"], key(d)))
        rows.append({**d, "tests_using": used[key(d)], "tests_naming": named[d["name"]]})
    return rows


def lists(rows):
    def item(row):
        return {"kind": row["kind"], "name": key(row), "clause": row["clause"], "file": row["file"]}
    unused = [item(r) for r in rows if r["kind"] in ("function", "task", "macro")
              and not r["tests_using"] and not r["tests_naming"]]
    name_only = [item(r) for r in rows if r["kind"] in ("function", "task")
                 and not r["tests_using"] and r["tests_naming"]]
    order = lambda i: (i["kind"], i["name"], i["clause"])   # noqa: E731
    return sorted(unused, key=order), sorted(name_only, key=order)


def counts(root=None):
    found = declarations(root or ROOT)
    return {"annotations": len(found), **{k: sum(d["kind"] == k for d in found) for k in KINDS},
            "other": sum(d["kind"] == "other" for d in found)}


def load(root=None):
    path = (root or ROOT) / RECORD
    require(path.is_file(), f"{RECORD}: missing; run update")
    return json.loads(path.read_text(encoding="utf-8"))


def validate_shape(data, root=None):
    root = root or ROOT
    require(set(data) == {"schema_version", "library", "purpose", "annotated", "unused",
                          "name_only"}, "record: unexpected fields")
    require(data["schema_version"] == 1, "record: schema_version must be 1")
    require(data["library"] == library_dir(root)[1], "record: library must be the pinned version")
    require(set(data["purpose"]) == {"en", "ja"}, "purpose: both en and ja text are required")
    require(data["annotated"] == counts(root),
            "record: annotated differs from the pinned library; run update")
    for name in ("unused", "name_only"):
        require(isinstance(data[name], list), f"{name}: expected a list")
        for item in data[name]:
            require(isinstance(item, dict) and set(item) == {"kind", "name", "clause", "file"},
                    f"{name}: an item has kind, name, clause and file")


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    if argv[:1] == ["resolve"]:   # the child process of one_test
        root = Path(argv[1])
        print(json.dumps(sorted(resolved(root / "tests" / (argv[2] + ".sv"), argv[3:], root))))
        return 0
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=("check", "update", "summary"))
    parser.add_argument("-j", "--jobs", type=int, default=os.cpu_count() or 1)
    parser.add_argument("--json", type=Path, help="write the counts of every declaration")
    parser.add_argument("--lang", choices=("en", "ja"), default="en")
    args = parser.parse_args(argv)
    try:
        if args.command == "summary":
            data = load()
            validate_shape(data)
            a = data["annotated"]
            kinds = ", ".join(f"{k} {a[k]}" for k in KINDS)
            print(f"{a['annotations']} annotations ({kinds}, other {a['other']}); "
                  f"{len(data['unused'])} unused, {len(data['name_only'])} named only"
                  if args.lang == "en" else
                  f"注釈{a['annotations']}行（{kinds}、その他{a['other']}）："
                  f"未使用{len(data['unused'])}件、名前だけ{len(data['name_only'])}件")
            return 0
        frontend = slang_elaborate.load()
        have = slang_elaborate.installed_version()
        require(have == frontend["version"],
                f"pyslang {frontend['version']} is needed, and {have or 'none'} is installed")
        rows = census(max(1, args.jobs))
        unused, name_only = lists(rows)
        if args.json:
            args.json.parent.mkdir(parents=True, exist_ok=True)
            args.json.write_text(json.dumps(rows, indent=1) + "\n", encoding="utf-8")
        if args.command == "update":
            path = ROOT / RECORD
            old = json.loads(path.read_text(encoding="utf-8")) if path.is_file() else {}
            data = {"schema_version": 1, "library": library_dir(ROOT)[1],
                    "purpose": old.get("purpose") or {"en": "", "ja": ""},
                    "annotated": counts(), "unused": unused, "name_only": name_only}
            path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                            encoding="utf-8")
            print(f"{RECORD}: {len(unused)} unused, {len(name_only)} named only")
            return 0
        data = load()
        validate_shape(data)
        for name, current in (("unused", unused), ("name_only", name_only)):
            was = {(i["kind"], i["name"]) for i in data[name]}
            now = {(i["kind"], i["name"]) for i in current}
            require(data[name] == current,
                    f"{name} differs from the tests: no longer {sorted(was - now)[:5]}, "
                    f"new {sorted(now - was)[:5]}; run update and review the change")
    except CensusError as error:
        print(f"api_census: {error}", file=sys.stderr)
        return 1
    print(f"{len(rows)} annotated declarations: {len(unused)} unused, "
          f"{len(name_only)} named only; the record matches")
    return 0


if __name__ == "__main__":
    sys.exit(main())

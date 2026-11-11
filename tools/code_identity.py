#!/usr/bin/env python3
"""Checks that an edit of the test sources keeps their code, and carries input
fingerprints across such an edit.

Usage:
    python3 tools/code_identity.py check --base REV
    python3 tools/code_identity.py refresh --base REV
    python3 tools/code_identity.py carry --base REV --record FILE --output FILE

Comments and line breaks make the tests easier to read (README.md, external
review item 8), but they change the input fingerprint of every test that
collects the edited file, so a stored record no longer applies to it. These
commands show that such an edit changes nothing that a simulator reads, and
only then move the fingerprints forward.

check compares every file under tests/ that differs between REV and the
working tree. The set of files must be the same. A file that is not a
SystemVerilog source (an expected output, C, data) must be byte-identical. A
SystemVerilog source must keep:

    tokens       the same tokens once comments and whitespace are removed
    header       the same metadata fields (the first /* ... */ block)
    directives   the same compiler-directive lines (`define, `include, ...),
                 including their line continuations
    metacomments the same comments that a tool may read as directives (those
                 that start with verilator, synopsys, pragma, coverage, lint
                 or translate)
    __LINE__     in a file that uses `__LINE__, the same line for every
                 token relative to the first one
    macro text   the same raw text of every macro use with arguments, which
                 a macro may turn into a string

A metacomment also keeps its place among the tokens. An input outside tests/
(the library lock, a C source) must be byte-identical for a fingerprint to move.

refresh then updates the input fingerprint of each entry of
coverage/test_index.json and coverage/known_causes.json whose recorded
fingerprint is the one at REV and whose inputs are all unchanged or
code-identical. carry does the same for a runner JSON, which keeps a record
that cannot be measured again (a guest run): each moved entry keeps its old
fingerprint in carried_from, and the record lists the step in
carried_forward. A record that was already stale at REV is left as it is.

A pass does not replace a new measurement where one is possible: the Verilator
results of an edited directory are measured again (docs/results.md, "Evidence
assembly").
"""

import argparse
import datetime
import functools
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

import suite_results

ROOT = suite_results.ROOT
SOURCES = {".sv", ".svh", ".v", ".vh"}
TOKEN = re.compile(r'''
    """.*?"""                                # triple-quoted string literal
  | "(?:\\.|[^"\\\n])*"                      # string literal
  | /\*.*?\*/                                # block comment
  | //[^\n]*                                 # line comment
  | \\\S+                                    # escaped identifier
  | `[A-Za-z_][A-Za-z0-9_$]*                 # directive or macro use
  | [A-Za-z_$][A-Za-z0-9_$]*                 # identifier or keyword
  | \d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?  # decimal or real number
  | '[sS]?[bBoOdDhH]?[0-9a-fA-FxXzZ?_]+     # based or unbased literal
  | &&&|<<<=|>>>=|<<=|>>=|===|!==|==\?|!=\?|<->|->>|\|->|\|=>|<<<|>>>
  | \+\+|--|&&|\|\||==|!=|<=|>=|<<|>>|\*\*|[-+*/%&|^]=|->|\+:|-:|::|\#\#|~[&|^]|\^~|'\{
  | \S                                       # any other character
''', re.X | re.S | re.A)
DIRECTIVE = re.compile(r"`(define|undef|undefineall|ifdef|ifndef|elsif|else|endif|include|"
                       r"timescale|resetall|default_nettype|line|pragma|celldefine|"
                       r"endcelldefine|begin_keywords|end_keywords|unconnected_drive|"
                       r"nounconnected_drive)\b")
METACOMMENT = re.compile(r"^(?://|/\*)\s*(verilator|synopsys|pragma|coverage|lint|translate)\b",
                         re.I)


class IdentityError(ValueError):
    """An edit changes code, or a record cannot be moved forward."""


def git(*args):
    return subprocess.run(["git", *args], cwd=ROOT, check=True, capture_output=True).stdout


def resolve(rev):
    try:
        return git("rev-parse", "--verify", rev + "^{commit}").decode().strip()
    except subprocess.CalledProcessError:
        raise IdentityError(f"unknown revision {rev}") from None


@functools.lru_cache(maxsize=None)
def at(rev, relative):
    """The bytes of a repository path at rev, or None if it does not exist."""
    try:
        return git("show", f"{rev}:{relative}")
    except subprocess.CalledProcessError:
        return None


def tokens(text):
    """(token, line) pairs of the code, and the comments with their lines."""
    code, comments = [], []
    line, last = 1, 0
    for m in TOKEN.finditer(text):
        tok = m.group(0)
        line += text.count("\n", last, m.start())
        last = m.start()
        if tok.startswith(("//", "/*")):
            comments.append((tok, line))
            if METACOMMENT.match(tok):
                code.append((tok, line))
        else:
            code.append((tok, line))
    return code, comments


def directive_lines(text):
    """The compiler-directive lines, each with its continuation lines."""
    lines, out, i = text.split("\n"), [], 0
    while i < len(lines):
        if DIRECTIVE.search(lines[i]):
            # Raw lines: a blank after the backslash ends the continuation.
            group = [lines[i]]
            while group[-1].endswith("\\") and i + 1 < len(lines):
                i += 1
                group.append(lines[i])
            out.append("\n".join(group))
        i += 1
    return out


def line_relations(code):
    """In a file that uses `__LINE__, the line of every token relative to the
    first one: such a file may only gain lines above its code."""
    if not any(tok == "`__LINE__" for tok, _ in code):
        return []
    first = code[0][1]
    return [line - first for _, line in code]


def macro_arguments(text):
    """The raw text of each macro use with arguments; a macro may turn an
    argument into a string, so its spacing and comments are kept exactly."""
    out = []
    for m in re.finditer(r"`[A-Za-z_][A-Za-z0-9_$]*[ \t]*\(", text):
        depth, i = 0, m.end() - 1
        while i < len(text):
            ch = text[i]
            if ch == '"':
                i = text.find('"', i + 1)
                while i > 0 and text[i - 1] == "\\":
                    i = text.find('"', i + 1)
                if i < 0:
                    break
            elif ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
                if depth == 0:
                    break
            i += 1
        out.append(text[m.start():i + 1])
    return out


def source_problems(old, new):
    """Why two versions of a SystemVerilog source differ in code, if they do."""
    old_text, new_text = old.decode("utf-8"), new.decode("utf-8")
    old_code, old_comments = tokens(old_text)
    new_code, new_comments = tokens(new_text)
    problems = []
    if [t for t, _ in old_code] != [t for t, _ in new_code]:
        first = next((i for i, (a, b) in enumerate(zip(old_code, new_code)) if a[0] != b[0]),
                     min(len(old_code), len(new_code)))
        where = new_code[first][1] if first < len(new_code) else "end"
        problems.append(f"tokens differ (new line {where})")
    if suite_header(old_text) != suite_header(new_text):
        problems.append("metadata fields differ")
    if directive_lines(old_text) != directive_lines(new_text):
        problems.append("compiler-directive lines differ")
    meta = [[t for t, _ in comments if METACOMMENT.match(t)]
            for comments in (old_comments, new_comments)]
    if meta[0] != meta[1]:
        problems.append("metacomments differ")
    if line_relations(old_code) != line_relations(new_code):
        problems.append("line distances around `__LINE__ differ")
    if macro_arguments(old_text) != macro_arguments(new_text):
        problems.append("the text of a macro's arguments differs")
    return problems


def suite_header(text):
    m = re.search(r"/\*(.*?)\*/", text, re.DOTALL)
    if not m:
        return {}
    return {k: v.strip() for k, v in re.findall(r"^:(\w+):\s*(.*)$", m.group(1), re.MULTILINE)}


def changed_files(base):
    """Paths under tests/ that differ between base and the working tree."""
    out = git("diff", "--name-status", "--no-renames", base, "--", "tests").decode()
    untracked = git("ls-files", "--others", "--exclude-standard", "--", "tests").decode()
    entries = [line.split("\t", 1) for line in out.splitlines() if line]
    entries += [["A", line] for line in untracked.splitlines() if line]
    return entries


def check(base):
    """Raises IdentityError unless every edit under tests/ keeps the code."""
    problems = []
    entries = changed_files(base)
    for status, path in entries:
        if status != "M":
            problems.append(f"{path}: {'added' if status == 'A' else 'removed or renamed'}")
            continue
        old, new = at(base, path), (ROOT / path).read_bytes()
        if Path(path).suffix in SOURCES:
            problems += [f"{path}: {p}" for p in source_problems(old, new)]
        elif old != new:
            problems.append(f"{path}: not a source, but its bytes differ")
    if problems:
        raise IdentityError("\n".join(problems))
    return [path for _, path in entries]


def digest_at(test, base):
    """input_digest of a test computed from the files as they were at base."""
    digest = hashlib.sha256()
    for path in suite_results.input_files(test):
        name = path.relative_to(ROOT).as_posix()
        content = at(base, name)
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256(content).digest() if content is not None else b"MISSING")
    return digest.hexdigest()


class Mover:
    """Moves recorded fingerprints from base to the working tree."""

    def __init__(self, base):
        self.base = resolve(base)
        check(self.base)
        self.tests = {suite_results.test_id(t): t for t in suite_results.find_tests(ROOT)}
        self.current, self.old = {}, {}

    def move(self, test_id, recorded):
        """The current fingerprint for a record made at base, or None to keep it."""
        test = self.tests.get(test_id)
        if test is None:
            return None
        if test_id not in self.current:
            self.current[test_id] = suite_results.input_digest(test)
        if recorded == self.current[test_id]:
            return None
        if test_id not in self.old:
            self.old[test_id] = digest_at(test, self.base)
        if recorded != self.old[test_id]:
            return None
        # check() covers tests/; any other input (the library lock, C sources)
        # must be byte-identical, or the record was made with something else.
        for path in suite_results.input_files(test):
            name = path.relative_to(ROOT).as_posix()
            if not name.startswith("tests/") and path.is_file() and at(self.base, name) != path.read_bytes():
                raise IdentityError(f"{name}: an input outside tests/ changed since {self.base[:7]}")
        return self.current[test_id]


def write_json(path, value, indent):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=indent) + "\n", encoding="utf-8")


def refresh(base):
    mover = Mover(base)
    moved = {}
    index_path = ROOT / "coverage" / "test_index.json"
    index = json.loads(index_path.read_text(encoding="utf-8"))
    n = 0
    for test_id, entry in index["tests"].items():
        new = mover.move(test_id, entry["inputs_sha256"])
        if new:
            entry["inputs_sha256"] = new
            n += 1
    write_json(index_path, index, 2)
    moved["coverage/test_index.json"] = n
    causes_path = ROOT / "coverage" / "known_causes.json"
    causes = json.loads(causes_path.read_text(encoding="utf-8"))
    n = 0
    for entry in causes["causes"]:
        new = mover.move(entry["test"], entry["inputs_sha256"])
        if new:
            entry["inputs_sha256"] = new
            n += 1
    write_json(causes_path, causes, 2)
    moved["coverage/known_causes.json"] = n
    return moved


def carry(base, record_path, output_path):
    mover = Mover(base)
    record = json.loads(record_path.read_text(encoding="utf-8"))
    n = 0
    for test_id, entry in record["tests"].items():
        recorded = entry.get("inputs_sha256")
        new = mover.move(test_id, recorded) if recorded else None
        if new:
            entry.setdefault("carried_from", recorded)
            entry["inputs_sha256"] = new
            n += 1
    record.setdefault("carried_forward", []).append({
        "base": mover.base, "records": n,
        "at": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
        "rule": "inputs code-identical to the base (tools/code_identity.py)"})
    write_json(output_path, record, 1)
    return n


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=("check", "refresh", "carry"))
    parser.add_argument("--base", required=True, help="the revision the edit starts from")
    parser.add_argument("--record", type=Path, help="a runner JSON to carry forward (carry)")
    parser.add_argument("--output", type=Path, help="where the carried record goes (carry)")
    args = parser.parse_args(argv)
    if (args.command == "carry") != (args.record is not None and args.output is not None):
        parser.error("--record and --output are for carry, and carry needs both")
    try:
        if args.command == "check":
            paths = check(resolve(args.base))
            print(f"{len(paths)} edited files under tests/ keep their code")
        elif args.command == "refresh":
            for name, n in refresh(args.base).items():
                print(f"{name}: {n} fingerprints moved forward")
        else:
            n = carry(args.base, args.record, args.output)
            print(f"{args.output.name}: {n} records carried forward")
    except (IdentityError, OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
        print(f"code_identity: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

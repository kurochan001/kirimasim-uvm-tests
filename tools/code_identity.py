#!/usr/bin/env python3
"""Checks that an edit of the test sources keeps their code, and carries input
fingerprints across such an edit.

Usage:
    python3 tools/code_identity.py check --base REV [--retag]
    python3 tools/code_identity.py refresh --base REV [--retag]
    python3 tools/code_identity.py carry --base REV --record FILE --output FILE [--retag]

Comments and line breaks make the tests easier to read (docs/testing.md,
"Readability edits"), but they change the input fingerprint of every test that
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

With --retag, the simulator tags of `:oracle:` and `:uvm_cmdline_oracle:`
(the words of the form verilator@RELEASE) may change, and every other word of
those fields and every other field must stay. These tags say which simulator a
test's expectation has been recorded with: no simulator reads them, and the
runners of kirimasim and Ghost do not use them to form a command or a verdict,
so a guest record stays a record of the same input. A Verilator record does
not: its verdict follows the tag, and it is measured again.

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
  | \d[\d_]*(?:\.\d[\d_]*)?(?:step|[munpf]?s)\b  # time literal: 1ns is not 1 ns
  | \d[\d_]*(?:\.\d[\d_]*)?(?:[eE][+-]?\d+)?  # decimal or real number
  | '[sS]?[bBoOdDhH]?[0-9a-fA-FxXzZ?_]+     # based or unbased literal
  | &&&|<<<=|>>>=|<<=|>>=|===|!==|==\?|!=\?|<->|->>|\|->|\|=>|<<<|>>>
  | \+\+|--|&&|\|\||==|!=|<=|>=|<<|>>|\*\*|[-+*/%&|^]=|->|\+:|-:|::|\#\#|~[&|^]|\^~|'\{
  | \#-\#|\#=\#|:=|:/|\.\*|=>|\*>|\(\*|\*\)|@@
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
    macro = None
    depth = 0
    for match in TOKEN.finditer(text):
        tok = match.group()
        if tok.startswith(("//", "/*")):
            continue
        if tok in ("(", "(*") and (depth or macro is not None):
            if not depth:
                start = macro
            depth += 1
        elif depth and tok in (")", "*)"):
            depth -= 1
            if not depth:
                out.append(text[start:match.end()])
        macro = match.start() if tok.startswith("`") else None
    if depth:
        out.append(text[start:])
    return out


ORACLE_FIELDS = ("oracle", "uvm_cmdline_oracle")
SIMULATOR_TAG = re.compile(r"verilator@\S+")


def without_simulator_tags(fields):
    """The metadata fields with the simulator tags of the oracle fields removed."""
    return {k: " ".join(w for w in v.split() if not SIMULATOR_TAG.fullmatch(w))
            if k in ORACLE_FIELDS else v for k, v in fields.items()}


def source_problems(old, new, retag=False):
    """Why two versions of a SystemVerilog source differ in code, if they do.
    With retag, the simulator tags of the oracle fields may differ."""
    old_text, new_text = old.decode("utf-8"), new.decode("utf-8")
    old_code, old_comments = tokens(old_text)
    new_code, new_comments = tokens(new_text)
    problems = []
    if [t for t, _ in old_code] != [t for t, _ in new_code]:
        first = next((i for i, (a, b) in enumerate(zip(old_code, new_code)) if a[0] != b[0]),
                     min(len(old_code), len(new_code)))
        where = new_code[first][1] if first < len(new_code) else "end"
        problems.append(f"tokens differ (new line {where})")
    old_fields, new_fields = suite_header(old_text), suite_header(new_text)
    if retag:
        old_fields, new_fields = without_simulator_tags(old_fields), without_simulator_tags(new_fields)
    if old_fields != new_fields:
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


def check(base, retag=False):
    """Raises IdentityError unless every edit under tests/ keeps the code."""
    problems = []
    entries = changed_files(base)
    for status, path in entries:
        if status != "M":
            problems.append(f"{path}: {'added' if status == 'A' else 'removed or renamed'}")
            continue
        old, new = at(base, path), (ROOT / path).read_bytes()
        if Path(path).suffix in SOURCES:
            problems += [f"{path}: {p}" for p in source_problems(old, new, retag)]
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

    def __init__(self, base, retag=False):
        self.base = resolve(base)
        self.retag = retag
        check(self.base, retag)
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
            if not name.startswith("tests/"):
                current = path.read_bytes() if path.is_file() else None
                if at(self.base, name) != current:
                    raise IdentityError(f"{name}: an input outside tests/ changed since {self.base[:7]}")
        return self.current[test_id]


def write_json(path, value, indent):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=indent) + "\n", encoding="utf-8")


def refresh(base, retag=False):
    mover = Mover(base, retag)
    moved = {}
    index_path = ROOT / "coverage" / "test_index.json"
    index = json.loads(index_path.read_text(encoding="utf-8"))
    n = 0
    for test_id, entry in index["tests"].items():
        new = mover.move(test_id, entry["inputs_sha256"])
        if new:
            entry["inputs_sha256"] = new
            n += 1
    moved["coverage/test_index.json"] = n
    causes_path = ROOT / "coverage" / "known_causes.json"
    causes = json.loads(causes_path.read_text(encoding="utf-8"))
    n = 0
    for entry in causes["causes"]:
        new = mover.move(entry["test"], entry["inputs_sha256"])
        if new:
            entry["inputs_sha256"] = new
            n += 1
    write_json(index_path, index, 2)
    write_json(causes_path, causes, 2)
    moved["coverage/known_causes.json"] = n
    return moved


def carry(base, record_path, output_path, retag=False):
    record = json.loads(record_path.read_text(encoding="utf-8"))
    if retag and record.get("simulator") not in ("ghost", "kirimasim"):
        raise IdentityError("--retag can carry only ghost or kirimasim records")
    mover = Mover(base, retag)
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
        "rule": "inputs code-identical to the base (tools/code_identity.py)"
                + ("; simulator tags of the oracle fields may differ" if retag else "")})
    write_json(output_path, record, 1)
    return n


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=("check", "refresh", "carry"))
    parser.add_argument("--base", required=True, help="the revision the edit starts from")
    parser.add_argument("--record", type=Path, help="a runner JSON to carry forward (carry)")
    parser.add_argument("--output", type=Path, help="where the carried record goes (carry)")
    parser.add_argument("--retag", action="store_true",
                        help="allow the simulator tags of the oracle fields to change")
    args = parser.parse_args(argv)
    if (args.command == "carry") != (args.record is not None and args.output is not None):
        parser.error("--record and --output are for carry, and carry needs both")
    try:
        if args.command == "check":
            paths = check(resolve(args.base), args.retag)
            print(f"{len(paths)} edited files under tests/ keep their code")
        elif args.command == "refresh":
            for name, n in refresh(args.base, args.retag).items():
                print(f"{name}: {n} fingerprints moved forward")
        else:
            n = carry(args.base, args.record, args.output, args.retag)
            print(f"{args.output.name}: {n} records carried forward")
    except (IdentityError, OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
        print(f"code_identity: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

"""Find implicit-lifetime initialized locals in initial/always blocks.

This is a lexical style check for the suite's standalone test sources, not
an SV parser. It recognizes begin/fork blocks, nested blocks, qualified and
parameterized types, and array declarations. It does not expand macros or
validate declarations inside functions/tasks, whose lifetime also depends
on the enclosing subroutine. Compiler checks remain necessary.
"""

from dataclasses import dataclass
import re


@dataclass(frozen=True)
class Token:
    value: str
    offset: int


@dataclass(frozen=True)
class Initializer:
    name: str
    line: int
    offset: int


# Preserve positions while discarding comment/string contents. A literal's
# punctuation and keywords must not affect block or declaration recognition.
OPAQUE = re.compile(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"', re.DOTALL)
TOKEN = re.compile(r'\\[^\s]+|[a-zA-Z_$][\w$]*|::|===|!==|==|!=|<=|>=|[^\s]')
IDENTIFIER = re.compile(r'[a-zA-Z_$][\w$]*\Z')
PROCESSES = {"initial", "always", "always_comb", "always_ff", "always_latch"}
OPEN = {"(": ")", "[": "]", "{": "}"}
CLOSE = set(OPEN.values())
BLOCK_END = {"begin": "end", "fork": "join"}
JOIN = {"join", "join_any", "join_none"}
CONTROL = {"if", "else", "for", "foreach", "while", "do", "repeat", "forever",
           "case", "casex", "casez", "endcase", "return", "wait", "wait_order",
           "disable", "force", "release", "assign", "deassign", "assert",
           "assume", "cover", "break", "continue"}


def tokens(source: str) -> list[Token]:
    masked = OPAQUE.sub(lambda m: re.sub(r'[^\n]', ' ', m.group()), source)
    return [Token(m.group(), m.start()) for m in TOKEN.finditer(masked)]


def group_end(items: list[Token], index: int) -> int:
    """Index just after a balanced parenthesized/bracketed/braced group."""
    stack = [OPEN[items[index].value]]
    index += 1
    while index < len(items) and stack:
        value = items[index].value
        if value in OPEN:
            stack.append(OPEN[value])
        elif value == stack[-1]:
            stack.pop()
        index += 1
    return index


def declaration(items: list[Token]) -> tuple[str, int] | None:
    """Return the first name and lifetime insertion point of an implicit init."""
    if not items:
        return None
    i = 0
    while i < len(items) and items[i].value in {"const", "var"}:
        i += 1
    if i == len(items) or items[i].value in {"automatic", "static"}:
        return None
    start = i
    base = items[i].value
    if base in CONTROL or not IDENTIFIER.fullmatch(base):
        return None
    i += 1
    # A data type may be scoped, parameterized, signed and/or packed.
    while i < len(items):
        value = items[i].value
        if value == "::" and i + 1 < len(items):
            i += 2
        elif value == "#" and i + 1 < len(items) and items[i + 1].value == "(":
            i = group_end(items, i + 1)
        elif value in {"signed", "unsigned", "packed"}:
            i += 1
        elif value == "[" or (value == "{" and base in {"struct", "union", "enum"}):
            i = group_end(items, i)
        else:
            break
    if i >= len(items) or not IDENTIFIER.fullmatch(items[i].value):
        return None
    name = items[i].value
    i += 1
    while i < len(items) and items[i].value == "[":
        i = group_end(items, i)
    if i >= len(items) or items[i].value not in {"=", ","}:
        return None
    # Ignore assignments nested inside bounds or initializer expressions.
    while i < len(items):
        value = items[i].value
        if value == "=":
            return name, items[start].offset
        if value in OPEN:
            i = group_end(items, i)
        else:
            i += 1
    return None


def implicit_initializers(source: str) -> list[Initializer]:
    items = tokens(source)
    found = []
    i = 0
    while i < len(items):
        if items[i].value not in PROCESSES:
            i += 1
            continue
        i += 1
        # Skip event/delay controls to the process's first block or statement.
        while i < len(items) and items[i].value not in {"begin", "fork", ";"}:
            if items[i].value in OPEN:
                i = group_end(items, i)
            else:
                i += 1
        if i == len(items) or items[i].value == ";":
            continue
        blocks = []
        groups = []
        start = i
        while i < len(items):
            value = items[i].value
            if value in OPEN:
                groups.append(OPEN[value])
            elif groups and value == groups[-1]:
                groups.pop()
            elif not groups:
                if value in BLOCK_END:
                    blocks.append(BLOCK_END[value])
                    i += 1
                    if i + 1 < len(items) and items[i].value == ":":
                        i += 2
                    start = i
                    continue
                if value == "end" or value in JOIN:
                    if blocks:
                        blocks.pop()
                    i += 1
                    if i + 1 < len(items) and items[i].value == ":":
                        i += 2
                    start = i
                    if not blocks:
                        break
                    continue
                if value == ";":
                    match = declaration(items[start:i])
                    if match:
                        name, offset = match
                        found.append(Initializer(name, source.count('\n', 0, offset) + 1, offset))
                    start = i + 1
            i += 1
    return found

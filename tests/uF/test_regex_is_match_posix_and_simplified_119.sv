/*
:name: test_regex_is_match_posix_and_simplified_119
:description: uvm_is_match treats a slash-delimited expression as a POSIX regular expression and any other expression as simplified notation with only star, plus and question mark (IEEE 1800.2-2020 Section F.3.3.1)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.3.3.1 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_cmdline_backend: vpi
:uvm_defines: UVM_HDL_NO_DPI
:dpi_c: @../../tools/cmdline_backend/uvm_cmdline_vpi.cpp
:files: ../../tools/cmdline_backend/uvm_cmdline_regex.cpp ../../tools/cmdline_backend/malloc.h
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_regex_is_match_posix_and_simplified_119.expected
*/
// What it checks:
// 1. uvm_is_match evaluates an expression surrounded by slashes as a POSIX
//    regular expression.
// 2. In simplified notation, plus matches one or more characters, star zero or
//    more and question mark exactly one.
// 3. Simplified notation has only three meta-characters, so a dot, a caret and
//    a dollar sign match themselves.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.3.3.1 (UVM-REGEX-IS-MATCH-POSIX) gives rule 1 above. Setup:
//    Match anchored expressions with a digit class and one-or-more repetition,
//    and with an alternation, against matching and nonmatching names.
//    Expected: The matching names match and the nonmatching name does not.
// 2. 1800.2-2020 F.3.3.1 (UVM-REGEX-IS-MATCH-SIMPLIFIED-METACHARACTERS) gives
//    rule 2 above. Setup: Match env.ag+ against env.ag1 and env.ag, env.ag*
//    against env.ag, and env.a? against env.ag. Expected: Plus needs at least
//    one character, star accepts none and question mark accepts one.
// 3. 1800.2-2020 F.3.3.1 (UVM-REGEX-IS-MATCH-SIMPLIFIED-LITERALS) gives rule 3
//    above. Setup: Match env.ag against envXag, and the unslashed ^env$
//    against the literal string ^env$ and against env. Expected: The dot does
//    not match another character, and ^env$ matches only its literal string.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Slash-delimited anchored expressions use a character class with one-or-more
// repetition and an alternation. Simplified expressions use plus for one or
// more characters, star and question mark, while a dot, a caret and a dollar
// sign stay literal. The pinned regex DPI and the original command-line VPI
// bridge are enabled; the ordinary UVM_NO_DPI condition cannot evaluate regular
// expressions, so this case runs only in the command-line condition. Only the
// lines that begin with "UT: " are compared.
module test_regex_is_match_posix_and_simplified_119;
  import uvm_pkg::*;

  initial begin
    $display("UT: posix anchored %0d alternation %0d rejects %0d",
             uvm_is_match("/^env\\.ag[0-9]+$/", "env.ag12"),
             uvm_is_match("/^env\\.(left|right)$/", "env.right"),
             !uvm_is_match("/^env\\.ag[0-9]+$/", "env.agx"));
    $display("UT: simplified plus %0d plus_empty %0d star_empty %0d question %0d",
             uvm_is_match("env.ag+", "env.ag1"), uvm_is_match("env.ag+", "env.ag"),
             uvm_is_match("env.ag*", "env.ag"), uvm_is_match("env.a?", "env.ag"));
    $display("UT: simplified dot_literal %0d unslashed_literal %0d %0d",
             !uvm_is_match("env.ag", "envXag"), uvm_is_match("^env$", "^env$"),
             !uvm_is_match("^env$", "env"));
    $finish;
  end
endmodule

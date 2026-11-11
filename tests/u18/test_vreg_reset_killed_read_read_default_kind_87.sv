/*
:name: test_vreg_reset_killed_read_read_default_kind_87
:description: vreg reset killed read read default kind observes standard access behavior with independent modeled storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.9.1.3.5 18.9.1.3.1 18.9.1.3.2 18.9.1.1.2 18.10.2.2 18.6.9.1 18.6.9.2 18.6.7.2 19.5.2.6 19.5.2.7 18.2.3.4 18.2.4.18 1800-2023 6.21 8.20 9.3.2 9.7
:uvm: 2020.3.1
:files: helpers87/killed_access_fixture87.svh
:incdirs: helpers87
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=test87
:expected_exit: 0
:expected_stdout: @test_vreg_reset_killed_read_read_default_kind_87.expected
*/
// What it checks:
// Explicit virtual-register reset restores access after a thread is killed
// during an unfinished array read or write.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.9.1.3.5 (UVM-ACCESS-VREG-RESET-KILLED-RECOVERY-87) gives the
// rule above. Setup: An original 16-bit user-backdoor memory implements a
// three-element virtual array at offset3,stride4 and an independent peer array
// at offset20. Each round proves both selected indices0/2 and the peer work,
// blocks a real virtual-register read or write inside the provider before
// storage completion, captures and kills that calling process, and proves the
// peer still works on the same provider. Only then reset() or reset("HARD") is
// called. A fresh read/write on the other array index must complete, followed
// by a read of the victim index and raw checks of all32 words. The four
// victim/recovery operation pairs and both argument forms are independent
// source inputs. Expected: The provider is entered and the victim has not
// returned before kill; the killed operation does not later commit or return.
// The independent peer remains usable, reset preserves the modeled words, and
// the fresh array access completes with its requested value/status while all
// unselected words remain unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Independent original testbench storage; no HDL or physical bus protocol.
module test_vreg_reset_killed_read_read_default_kind_87;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=0;
  localparam string CASE_NAME="vreg_reset_killed_read_read_default_kind";
  localparam bit EXPLICIT_KIND=0;
  `include "killed_access_fixture87.svh"
  initial run_test("test87");
  initial begin #5000; $fatal(1,"access87 watchdog"); end
endmodule

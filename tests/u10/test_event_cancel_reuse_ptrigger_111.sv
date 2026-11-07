/*
:name: test_event_cancel_reuse_ptrigger_111
:description: event cancel/count reuse with ptrigger waiters (IEEE 1800.2-2020 Section 10.1.1.2.9)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.1.1.2.9 10.1.1.2.10 10.1.1.2.2 10.1.1.2.3 10.1.1.2.4 10.1.1.2.5 10.1.1.2.8 10.1.2.2.1 10.1.2.2.4 1800-2023 6.21 9.3.2 9.7
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_cancel_reuse_ptrigger_111.expected
:files: helpers111_cancel/event_cancel111.svh
*/
// Two explicit kill/cancel pairs leave one real waiter blocked until its
// controlled release. Reuse the same event; keep a separate peer pending.
// No live-process cancellation, between-pair count or winner order is fixed.
module test_event_cancel_reuse_ptrigger_111;
  import uvm_pkg::*;
  localparam int STYLE111=1;
  `include "event_cancel111.svh"
  initial begin exercise111(); $finish; end
  initial begin #80; $fatal(1,"event111 cancellation watchdog expired"); end
endmodule

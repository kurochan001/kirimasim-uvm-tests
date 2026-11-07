/*
:name: test_objection_reraise_callback_descendant_fewer_106
:description: Re-raising across a pending zero-count chain preserves net ancestor counts
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.4 10.5.1.3.3 10.5.1.3.1 10.5.1.3.2 10.5.1.3.5 10.5.1.3.6 10.5.1.3.7 10.5.1.4.3 10.5.1.5.3 10.5.1.5.4 10.5.2.2.1 10.5.2.2.2 10.5.2.2.3 D.4.2 1800-2023 6.21 9.4.1 9.4.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers106_objection/objection106.svh
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_objection_reraise_callback_descendant_fewer_106.expected
*/
// Explicit gates distinguish drain time from the documented task callback.
// Public counts expose pending-drop compensation and source/peer isolation.
// No component task replaces the separately tested printed function hook.
// Negative net adjustments do not prescribe a compensation-hook encoding.
module test_objection_reraise_callback_descendant_fewer_106;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam bit CALLBACK106=1,DESCENDANT106=1;
  localparam bit REGISTERED106=0;
  localparam int OLD106=3,NEW106=1,PEER106=4,DRAIN106=2;
  `include "objection106.svh"
  initial run_test();
  initial begin #200; $fatal(1,"pending objection watchdog expired"); end
endmodule

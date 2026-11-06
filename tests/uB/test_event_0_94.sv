/*
:name: test_event_0_94
:description: Bare event field copying shares the selected event and a negative copy flag preserves an independent event
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.2.1.6 B.2.2 5.3.8.1 F.2.1.8 F.2.1.9 1800-2023 6.21 8.20 8.21 13.5.2 15.5.5 15.5.5.1 15.5.5.3
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers94_event/event_fixture94.svh
:expected_exit: 0
:expected_stdout: @test_event_0_94.expected
*/
module test_event_0_94;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=0;
  `include "event_fixture94.svh"
endmodule

/*
:name: test_root_1_94
:description: Implicit root parents and live component/object views agree under a qualified reading of the printed root declaration
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7 F.7.1 F.7.2.2 13.1.2.1 13.1.3.1 13.1.3.4 1800-2023 6.21 8.20 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers94_root/root_fixture94.svh
:expected_exit: 0
:expected_stdout: @test_root_1_94.expected
*/
module test_root_1_94;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=1;
  `include "root_fixture94.svh"
endmodule

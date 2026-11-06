/*
:name: test_registry_1_94
:description: Low-level registration macros preserve custom lookup strings and the selected concrete class without utility macros
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.1.4 B.2.1.5 8.3.1.2.1 8.3.1.5 8.3.1.7.3 5.3.3.1 1800-2023 6.21 8.20 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers94_registry/registry_fixture94.svh
:expected_exit: 0
:expected_stdout: @test_registry_1_94.expected
*/
module test_registry_1_94;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=1;
  localparam bit COMPONENT94=0;
  `include "registry_fixture94.svh"
endmodule

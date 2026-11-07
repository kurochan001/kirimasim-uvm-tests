/*
:name: test_inherited_api_callback_0_99
:description: Selected inherited APIs preserve documented name and identity semantics through original bridge and leaf types
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4.3 5.3.4.1 5.3.4.2 5.3.4.4 10.7.1.1 10.7.1.2.1 10.7.1.2.2 10.7.1.2.3 1800-2023 6.21 8.13 8.14 8.15 8.16
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers99/inherited_api99.svh
:expected_exit: 0
:expected_stdout: @test_inherited_api_callback_0_99.expected
*/
module test_inherited_api_callback_0_99;
  import uvm_pkg::*;
  localparam int FAMILY99=1;
  localparam int VARIANT99=0;
  localparam string FAMILY_NAME99="callback";
  `include "inherited_api99.svh"
endmodule

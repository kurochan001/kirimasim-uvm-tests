/*
:name: test_case_sensitive_component_0_101
:description: Selected UVM names differing only by case retain exact lookup and state under changed construction and lifecycle conditions
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4 13.1.2.1 13.1.3.3 13.1.3.4 13.1.3.5 13.1.3.6 13.1.3.7 1.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers101_component/component101.svh
:expected_exit: 0
:expected_stdout: @test_case_sensitive_component_0_101.expected
*/
module test_case_sensitive_component_0_101;
  import uvm_pkg::*;
  localparam int VARIANT101=0;
  `include "component101.svh"
endmodule

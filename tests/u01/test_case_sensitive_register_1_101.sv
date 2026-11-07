/*
:name: test_case_sensitive_register_1_101
:description: Selected UVM names differing only by case retain exact lookup and state under changed construction and lifecycle conditions
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4 18.1.3.14 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.2.3.4 18.2.3.5 18.4.2.1 18.4.2.2 18.5.3.2 18.6.3.1 18.6.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers101_model/model101.svh
:expected_exit: 0
:expected_stdout: @test_case_sensitive_register_1_101.expected
*/
module test_case_sensitive_register_1_101;
  import uvm_pkg::*;
  localparam int VARIANT101=1;
  localparam int FAMILY101=0;
  `include "model101.svh"
endmodule

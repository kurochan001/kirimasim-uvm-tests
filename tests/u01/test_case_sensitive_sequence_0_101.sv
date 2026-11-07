/*
:name: test_case_sensitive_sequence_0_101
:description: Selected UVM names differing only by case retain exact lookup and state under changed construction and lifecycle conditions
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4 14.1.2.7 14.1.2.8 14.1.2.9 14.2.3.1 14.1.2.12 14.1.2.13 14.1.2.14 5.3.4.1 5.3.4.2 5.3.4.4 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers101_sequence/sequence101.svh
:expected_exit: 0
:expected_stdout: @test_case_sensitive_sequence_0_101.expected
*/
module test_case_sensitive_sequence_0_101;
  import uvm_pkg::*;
  localparam int VARIANT101=0;
  `include "sequence101.svh"
endmodule

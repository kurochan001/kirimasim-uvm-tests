/*
:name: test_case_sensitive_pool_1_101
:description: Selected UVM names differing only by case retain exact lookup and state under changed construction and lifecycle conditions
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4 11.2.1 11.2.2.1 11.2.2.4 11.2.2.5 11.2.2.6 11.2.2.7 11.2.2.8 11.2.2.9 11.2.2.11 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers101_pool/pool101.svh
:expected_exit: 0
:expected_stdout: @test_case_sensitive_pool_1_101.expected
*/
module test_case_sensitive_pool_1_101;
  import uvm_pkg::*;
  localparam int VARIANT101=1;
  `include "pool101.svh"
endmodule

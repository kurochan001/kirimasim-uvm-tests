/*
:name: test_boolean_return_lock_0_98
:description: One-sided Boolean predicate descriptions imply the opposite return for valid nonmatching model states
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4.2 18.1.2.10 18.1.2.6 18.1.2.7 18.1.2.2 18.1.2.3 18.2.3.3 18.2.3.5 18.4.2.2 18.5.3.2 1800-2023 6.11 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers98/return_predicates98.svh
:expected_exit: 0
:expected_stdout: @test_boolean_return_lock_0_98.expected
*/
module test_boolean_return_lock_0_98;
  import uvm_pkg::*;
  localparam int FAMILY98=0;
  localparam int VARIANT98=0;
  localparam string FAMILY_NAME98="lock";
  `include "return_predicates98.svh"
endmodule

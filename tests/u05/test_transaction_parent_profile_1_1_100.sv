/*
:name: test_transaction_parent_profile_1_1_100
:description: Current transaction begin records and links the selected parent before its hook and named event, with omitted/zero controls
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.4.2.4 5.4.2.5 5.4.2.6 5.4.2.8 5.4.2.11 5.4.2.13 5.4.2.16 7.1.3.1 7.1.4.1 7.1.5 7.1.6.1 7.1.6.2 7.1.6.3 7.1.6.4 7.2.5.1 7.2.7.1 7.2.7.2 7.2.7.3 7.2.7.4 7.3.1.3.1 7.3.1.3.3 7.3.2 10.2.2.3 10.7.2.2.2 16.4.5.1 16.4.5.2 16.4.7.1 16.4.7.2 16.4.7.3 16.4.7.4 16.4.7.5 16.4.7.6 16.4.7.9 16.4.7.10 16.4.7.11 1800-2023 6.16 6.16.2 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_transaction_parent_profile_1_1_100.expected
:files: helpers100/transaction_parent100.svh
*/
module test_transaction_parent_profile_1_1_100;
  import uvm_pkg::*;
  localparam int MODE100=1,VARIANT100=1;
  `include "transaction_parent100.svh"
endmodule
